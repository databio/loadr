# loadr: Cleaner R workspaces

`loadr` is meant to help declutter R workspaces for very complex analyses that use substantial reference data, like is common in genomics. It provides a few functions that encourage you to use R `environment` objects to organize your variables so they are not all in the primary workspace. By sequestering reference data into a separate 'shared variable' environment, you make it easier to find R objects you're actively using.

## Install

```R
devtools::install_github("databio/loadr")
```

## Quick start:

```{r}
library('loadr')
eload(list(myReferenceDataVar=15))
SV$myReferenceDataVar
```

