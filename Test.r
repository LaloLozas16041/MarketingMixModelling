install.packages("rmarkdown")
install.packages("pandoc")

library(rmarkdown)
render("1-example.Rmd")

?rmarkdown::pandoc_available

pandoc_available(version = NULL, error = FALSE)
pandoc_version()


## Not run: 
library(rmarkdown)
if (pandoc_available())
  cat("pandoc", as.character(pandoc_version()), "is available!\n")
if (pandoc_available("1.12.3"))
  cat("required version of pandoc is available!\n")
## End(Not run)

