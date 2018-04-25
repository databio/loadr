# PACKAGE DOCUMENTATION
#' Cleaner R workspaces.
#'
#' Functions for loading data into a shared variable environment
#'
#' @docType package
#' @name loadr
#' @author Nathan Sheffield
#'
#' @references \url{http://github.com/databio/loadr}
NULL

# 

#' Show shared variables
#' Gives a list of shared variable contents.
#' @export
sv = function(envir="SV") {
	envirToCheck = getLoadEnvir(envir)
	sapply(envirToCheck, length)
}

#' Sets or getsa global variable specifying the default environment name for
#' \code{\link{loadr}}.
#'
#' @param envName Name of environment where shared variables should be stored.
#'     Leave NULL to retrieve current environment name.
#' @export
#' @examples
#' loadrEnv("SV")
loadrEnv = function(envName=NULL) {
	if (is.null(envName)) {
		return(options("LOADRENV")$LOADRENV)
	}
	options(LOADRENV=envName)
}



#' Loads R objects into the shared variable environment.
#' 
#' This function loads one or more R objects into the shared variable
#' environment. By default it will assign variable names as they are named when
#' passed to the function, but it can also assign variables to alternative names
#' using the varNames argument.
#' @param ... Any number of variables to assign to the shared variable environment
#' @param varNames (Optional) character vector of variable names to use for the
#'     given variables. If provided, the length of varNames must match the number
#'     of variables passed to ....
#' @export
#' @examples
#' x=5; y=7; z=15
#' vload(x, y, z)
#' vload(c(1,2,3), varNames="varname")
#' vload(x, y, varNames=c("xvar", "yvar"))
vload = function(..., varNames=NULL) {
	l = list(...)
	if (!is.null(varNames)) {
		if (length(varNames) != length(l)) {
			stop("Number of items must match number of names if varNames is provided")
		}
		names(l) = varNames
	} else {
		fcall = match.call(expand.dots=FALSE)
		if (!is.null(names(list(...)))) {
	        names(l)[names(l) == ""] = fcall[[2]][names(l) == ""]
	    } else {
	        names(l) = fcall[[2]]
	    }
	}
	eload(l)
}


#' A function used by eload() to create the global shared variable
#' repository if it doesn't exist, or return it if it does.
#' Internal function.
getLoadEnvir = function(loadEnvir=loadrEnv()) {
	if (!exists(loadEnvir)) { 
		loadEnvir = new.env(parent=emptyenv())
	} else {
		loadEnvir = get(loadEnvir, pos=globalenv())
	}
	return(loadEnvir)
}


#' Loader of mapping of names to values into variables within an environment
#'
#' \code{eload} takes a collection of bindings between name and value and 
#' uses those bindings to create or update an environment. A value for 
#  an already-bound name in the target environment may be either replaced or 
#' preserved according to the argument to \code{preserve}. If you want to load
#' directly into the current env, look at \code{list2env} with
#' \code{environment()}
#'
#' @param loadDat Collection of bindings between name and value, e.g. a 
#'                \code{list} or \code{environment}
#' @param loadEnvir Name (character string) for the environment to create or
#'     update.
#' @param preserve Whether to retain the value for an already-bound name.
#' @export
eload = function(loadDat, loadEnvir=loadrEnv(), preserve=FALSE) {
	if (is.null(loadEnvir)) {
		# Got a NULL environment. Create a default environment
		message("NULL environment; using environment SV...")
		loadEnvir="SV"
		loadrEnv(loadEnvir)
	}
	
	# Define the various collections of names.
	localEnvir = getLoadEnvir(loadEnvir)

	existing = ls(localEnvir)
	provided = names(loadDat)
	added = setdiff(provided, existing)
	
	# Determine how to do the iteration for the assignments.
	if (preserve) {
		updated = c()    # So that message calls at end of function are the same
		keys = added
	} else {
		updated = intersect(provided, existing)
		keys = provided
	}

	# Iterate over the collection appropriate given the desire for preservation.
	for(k in keys) {
		localEnvir[[k]] = loadDat[[k]]
	}

	# In the global environment, bind the given name to the environment.
	assign(loadEnvir, localEnvir, pos=globalenv())

	message("Newly Loaded: ", paste0(added, collapse=", "))
	message("Updated: ", paste0(updated, collapse=", "))
	message("Unchanged: ", paste0(setdiff(existing, updated), collapse=", "))
}
