#install.packages("PASWR2")
#install.packages("fpp2")

#install.packages("Robyn")
#install.packages("reticulate")

library(reticulate)
library(Robyn)

virtualenv_create("r-reticulate")
py_install("nevergrad", pip = TRUE)
use_virtualenv("r-reticulate", required = TRUE)