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
#' @param envir Character vector name of the environment to display.
#' @export
#' @examples
#' sv()
sv = function(envir="SV") {
	envirToCheck = getLoadEnvir(envir)
	sapply(envirToCheck, length)
}

#' Sets or gets a global variable specifying the default environment name for
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
#' environment if it doesn't exist, or return it if it does.
#' @param loadEnvir Name of the environment to get.
#' Internal function.
getLoadEnvir = function(loadEnvir=loadrEnv()) {
	if (!exists(loadEnvir)) { 
		loadEnvir = new.env(parent=emptyenv())
	} else {
		loadEnvir = get(loadEnvir, pos=globalenv())
	}
	return(loadEnvir)
}


#' Loads named variables into a shared environment
#'
#' \code{eload} takes a collection of named objects and creates or updates an
#' environment. By default, an existing variable in the target environment will
#' be replaced by a new value, but this can be avoided by setting
#' \code{preserve=TRUE}. If you want to load directly into the current env, look
#' at \code{list2env} with
#' \code{environment()}
#'
#' @param loadDat A \code{list} or \code{environment} with named variables to load.
#' @param loadEnvir Name (character string) for the environment to create or
#'     update.
#' @param preserve Whether to retain the value for an already-bound name.
#' @param parentEnvir Parent environment of the shared variable environment;
#'     defaults to \code{globalenv()}
#' @export
#' @examples
#' eload(list(x=15))
#' SV$x
eload = function(loadDat, loadEnvir=loadrEnv(), preserve=FALSE, parentEnvir=globalenv()) {
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
	assign(loadEnvir, localEnvir, pos=parentEnvir)
	
	if (length(added) > 0){
		message("Newly Loaded: ", paste0(added, collapse=", "))
	}
	if (length(updated) > 0){
		message("Updated: ", paste0(updated, collapse=", "))
	}
	unchanged = setdiff(existing, updated)
	if (length(unchanged) > 0){
		message("Unchanged: ", paste0(unchanged, collapse=", "))
	}
}
