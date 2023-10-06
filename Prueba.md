Guía Definitiva para el Marketing Mix Modelling
================

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

## Including Plots

You can also embed plots, for example:

![](Prueba_files/figure-gfm/pressure-1.png)<!-- -->

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.
