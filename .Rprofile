installPackagesNeeded <- function(reset = TRUE) {
  if (!require("pak")) install.packages("pak")
  library(pak)
  pak_cleanup(force = T)
  local_install_dev_deps(ask = F)
  if (reset & rstudioapi::isAvailable()) {
    rstudioapi::restartSession()
  } else {
    source(here::here(".Rprofile"))
  }
}

removeAllPacakges <- function() {
  remove.packages( installed.packages( priority = "NA" )[,1] )
}

options(
  repos=c(CRAN="https://cran.radicaldevelop.com/"),
  tidyverse.quiet = TRUE
)

tryCatch({
  here::i_am("README.md")
  library(here)
  library(tidyverse)
  library(conflicted)
  conflicted::conflict_prefer("filter", "dplyr", c("base", "stats"))
}, error = \(x) warning("Something went wrong, probably a package is not installed, do installPackagesNeeded()")
)


