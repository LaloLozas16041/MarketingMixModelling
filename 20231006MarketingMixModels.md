Guía Definitiva para el Marketing Mix Modelling
================

\#`{r setup, include=FALSE} #knitr::opts_chunk$set(echo = TRUE) #`

## Introducción

Ya sea que se trate de una empresa establecida o bastante nueva en el
mercado, casi todas las empresas utilizan diferentes canales de
marketing como televisión, radio, correo electrónico, redes sociales,
etc., para llegar a sus clientes potenciales y aumentar el conocimiento
de su producto y, a su vez, maximizar las ventas o ingresos.

Pero con tantos canales de marketing a su disposición, las empresas
deben decidir qué canales de marketing son eficaces en comparación con
otros y, lo que es más importante, cuánto presupuesto se debe asignar a
cada canal. Con el surgimiento del marketing online y varias plataformas
y herramientas de big data, el marketing es una de las áreas de
oportunidades más destacadas para las aplicaciones de ciencia de datos y
aprendizaje automático.

<strong>Objetivos de aprendizaje</strong>
</p>
<ol>
<li>
¿Qué es el Marketing Mix Modelling y por qué MMM con Robyn es mejor que
un MMM tradicional?
</li>
<li>
Componentes de las series temporales: tendencia, estacionalidad,
ciclicidad, ruido, etc.
</li>
<li>
Adstocks publicitarios: efecto de arrastre y efecto de rendimientos
decrecientes, y transformación de Adstock: geométrico, Weibull CDF y
Weibull PDF.
</li>
<li>
¿Qué son la optimización sin gradientes y la optimización de
hiperparámetros multiobjetivo con Nevergrad?
</li>
<li>
Implementación del Marketing Mix Modelling utilizando Robyn.
</li>
</ol>

Entonces, sin más preámbulos, demos el primer paso para comprender cómo
implementar el Marketing Mix Modelling utilizando la biblioteca Robyn
desarrollada por el equipo de Facebook (ahora Meta) y, lo más
importante, cómo interpretar los resultados de salida.

## Estacionalidad

Si observa un ciclo periódico en la serie con frecuencias fijas,
entonces puede decir que hay una estacionalidad en los datos. Estas
frecuencias pueden ser diarias, semanales, mensuales, etc. En palabras
simples, la estacionalidad siempre es de un período fijo y conocido, lo
que significa que notará una cantidad de tiempo definida entre los picos
y los valles de los datos; ergo, a veces, las series de tiempo
estacionales también se denominan series de tiempo periódicas.

Por ejemplo, las ventas minoristas aumentan en algunos festivales o
eventos en particular, o la temperatura del clima muestra su
comportamiento estacional de días cálidos en verano y días fríos en
invierno, etc.

``` 2
ggseasonplot(AirPassengers)
```

``` 2
#Step 1.a.First Install required Packages
install.packages("Robyn")
install.packages("reticulate")
library(reticulate)

#Step 1.b Setup virtual Environment & Install nevergrad library
virtualenv_create("r-reticulate")
py_install("nevergrad", pip = TRUE)
use_virtualenv("r-reticulate", required = TRUE)
```

``` 3
use_python("~/Library/r-miniconda/envs/r-reticulate/bin/python")
```

``` 4
#Step 1.c Import packages & set CWD
library(Robyn) 
library(reticulate)
set.seed(123)

setwd("E:/DataScience/MMM")

#Step 1.d You can force multi-core usage by running below line of code
Sys.setenv(R_FUTURE_FORK_ENABLE = "true")
options(future.fork.enable = TRUE)

# You can set create_files to FALSE to avoid the creation of files locally
create_files <- TRUE
```

``` 5
#Step 2.a Load data
data("dt_simulated_weekly")
head(dt_simulated_weekly)

#Step 2.b Load holidays data from Prophet
data("dt_prophet_holidays")
head(dt_prophet_holidays)

# Export results to desired directory.
robyn_object<- "~/MyRobyn.RDS"
```

``` 5
#### Step 3.1: Specify input variables

InputCollect <- robyn_inputs(
  dt_input = dt_simulated_weekly,
  dt_holidays = dt_prophet_holidays,
  dep_var = "revenue",
  dep_var_type = "revenue",
  date_var = "DATE",
  prophet_country = "DE",
  prophet_vars = c("trend", "season", "holiday"), 
  context_vars = c("competitor_sales_B", "events"),
  paid_media_vars = c("tv_S", "ooh_S", "print_S", "facebook_I", "search_clicks_P"),
  paid_media_spends = c("tv_S", "ooh_S", "print_S", "facebook_S", "search_S"),
  organic_vars = "newsletter", 
  # factor_vars = c("events"),
  adstock = "geometric", 
  window_start = "2016-01-01",
  window_end = "2018-12-31",
  
)
print(InputCollect)
```

``` 6
hyper_names(adstock = InputCollect$adstock, all_media = InputCollect$all_media)

## Note: Set plot = TRUE to produce example plots for 
#adstock & saturation hyperparameters.

plot_adstock(plot = FALSE)
plot_saturation(plot = FALSE)

# To check maximum lower and upper bounds
hyper_limits()
```

``` 7
# Specify hyperparameters ranges for Geometric adstock
hyperparameters <- list(
  facebook_S_alphas = c(0.5, 3),
  facebook_S_gammas = c(0.3, 1),
  facebook_S_thetas = c(0, 0.3),
  print_S_alphas = c(0.5, 3),
  print_S_gammas = c(0.3, 1),
  print_S_thetas = c(0.1, 0.4),
  tv_S_alphas = c(0.5, 3),
  tv_S_gammas = c(0.3, 1),
  tv_S_thetas = c(0.3, 0.8),
  search_S_alphas = c(0.5, 3),
  search_S_gammas = c(0.3, 1),
  search_S_thetas = c(0, 0.3),
  ooh_S_alphas = c(0.5, 3),
  ooh_S_gammas = c(0.3, 1),
  ooh_S_thetas = c(0.1, 0.4),
  newsletter_alphas = c(0.5, 3),
  newsletter_gammas = c(0.3, 1),
  newsletter_thetas = c(0.1, 0.4),
  train_size = c(0.5, 0.8)
)

#Add hyperparameters into robyn_inputs()

InputCollect <- robyn_inputs(InputCollect = InputCollect, hyperparameters = hyperparameters)
print(InputCollect)
```

``` 8
##### Save InputCollect in the format of JSON file to import later
robyn_write(InputCollect, dir = "./")

InputCollect <- robyn_inputs(
  dt_input = dt_simulated_weekly,
  dt_holidays = dt_prophet_holidays,
  json_file = "./RobynModel-inputs.json")
```

``` 9
calibration_input <- data.frame(
  liftStartDate = as.Date(c("2018-05-01", "2018-04-03", "2018-07-01", "2017-12-01")),
  liftEndDate = as.Date(c("2018-06-10", "2018-06-03", "2018-07-20", "2017-12-31")),
  liftAbs = c(400000, 300000, 700000, 200),
  channel = c("facebook_S",  "tv_S", "facebook_S+search_S", "newsletter"),
  spend = c(421000, 7100, 350000, 0),
  confidence = c(0.85, 0.8, 0.99, 0.95),
  calibration_scope = c("immediate", "immediate", "immediate", "immediate"),
  metric = c("revenue", "revenue", "revenue", "revenue")

)
InputCollect <- robyn_inputs(InputCollect = InputCollect, calibration_input = calibration_input)
```

``` 10
#Build an initial model

OutputModels <- robyn_run(
  InputCollect = InputCollect,
  cores = NULL,
  iterations = 2000,
  trials = 5,
  ts_validation = TRUE,
  add_penalty_factor = FALSE
)
print(OutputModels)
```

``` 11
## Calculate Pareto fronts, cluster and export results and plots.

OutputCollect <- robyn_outputs(
  InputCollect, OutputModels,
  csv_out = "pareto",
  pareto_fronts = "auto",
  clusters = TRUE,
  export = create_files,
  plot_pareto = create_files,
  plot_folder = robyn_object

)
print(OutputCollect)
```

``` 12
#Step 6: Select and save any one model

## Compare all model one-pagers and select one that largely reflects your business reality.
print(OutputCollect)
select_model <- "4_153_2"

ExportedModel <- robyn_write(InputCollect, OutputCollect, select_model, export = create_files)
print(ExportedModel)
```

``` 13
#Get budget allocation based on the selected model above

# Check media summary for selected model
print(ExportedModel)

# NOTE: The order of constraints should follow:
InputCollect$paid_media_spends

AllocatorCollect1 <- robyn_allocator(
  InputCollect = InputCollect,
  OutputCollect = OutputCollect,
  select_model = select_model,
  date_range = NULL,
  scenario = "max_historical_response",
  channel_constr_low = 0.7,
  channel_constr_up = c(1.2, 1.5, 1.5, 1.5, 1.5),
  channel_constr_multiplier = 3,
  export = create_files
)
# Print the budget allocator output summary
print(AllocatorCollect1)

# Plot the budget allocator one-pager
plot(AllocatorCollect1)
```

``` 14
```

## Including Plots

You can also embed plots, for example:

![](20231006MarketingMixModels_files/figure-gfm/pressure-1.png)<!-- -->

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.
