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
estacionales también se denominan series de tiempo periódicas. no Por
ejemplo, las ventas minoristas aumentan en algunos festivales o eventos
en particular, o la temperatura del clima muestra su comportamiento
estacional de días cálidos en verano y días fríos en invierno, etc.

``` r
library(forecast) # Librería clásica de Pronósticos
```

    ## Warning: package 'forecast' was built under R version 4.2.3

    ## Registered S3 method overwritten by 'quantmod':
    ##   method            from
    ##   as.zoo.data.frame zoo

``` r
ggseasonplot(AirPassengers)
```

![](20231006MarketingMixModels_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

``` r
library(fpp2) # Librería con la información para ilustrar ***
```

    ## Warning: package 'fpp2' was built under R version 4.2.3

    ## ── Attaching packages ────────────────────────────────────────────── fpp2 2.5 ──

    ## ✔ ggplot2   3.4.2     ✔ expsmooth 2.3  
    ## ✔ fma       2.5

    ## Warning: package 'ggplot2' was built under R version 4.2.3

    ## Warning: package 'fma' was built under R version 4.2.3

    ## Warning: package 'expsmooth' was built under R version 4.2.3

    ## 

``` r
autoplot(lynx) + xlab("Anio") + ylab("Número de linces atrapados")
```

![](20231006MarketingMixModels_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

## Paso 1: Instalar los paquetes adecuados

### Paso 1.a.Primera instalación de los paquetes necesarios, descomentar la primera vez

``` r
#install.packages("Robyn")
#install.packages("reticulate")
library(reticulate)
```

    ## Warning: package 'reticulate' was built under R version 4.2.3

``` r
library(Robyn)
```

    ## Warning: package 'Robyn' was built under R version 4.2.3

### Paso 1.b Configurar el entorno virtual e instalar la biblioteca Nevergrad

``` r
virtualenv_create("r-reticulate")
```

    ## virtualenv: r-reticulate

``` r
py_install("nevergrad", pip = TRUE)
#use_virtualenv("r-reticulate", required = TRUE) #Descomentar esta parte la primera vez
```

### Paso 1.c Importar paquetes y configurar CWD

``` r
library(Robyn) 
library(reticulate)
set.seed(123)

setwd('MMM')
```

``` r
#Paso 1.d Puedes forzar el uso de múltiples núcleos ejecutando la siguiente línea de código
Sys.setenv(R_FUTURE_FORK_ENABLE = "true")
options(future.fork.enable = TRUE)

# Puedes configurar create_files en FALSE para evitar la creación de archivos localmente
create_files <- TRUE
```

## Paso 2: Cargar Datos

``` r
#Paso 2.a Cargar datos
data("dt_simulated_weekly")
head(dt_simulated_weekly)
```

    ## # A tibble: 6 × 12
    ##   DATE        revenue    tv_S  ooh_S print_S facebook_I search_clicks_P search_S
    ##   <date>        <dbl>   <dbl>  <dbl>   <dbl>      <dbl>           <dbl>    <dbl>
    ## 1 2015-11-23 2754372.  67075. 0       38185.  72903853.              0         0
    ## 2 2015-11-30 2584277.  85840. 0           0   16581100.          29512.    12400
    ## 3 2015-12-07 2547387.      0  3.97e5   1362.  49954774.          36132.    11360
    ## 4 2015-12-14 2875220  250351. 0       53040   31649297.          36804.    12760
    ## 5 2015-12-21 2215953.      0  8.32e5      0    8802269.          28402.    10840
    ## 6 2015-12-28 2569922.  99676. 0       95767.  49902081.          38062.    11320
    ## # ℹ 4 more variables: competitor_sales_B <int>, facebook_S <dbl>, events <chr>,
    ## #   newsletter <dbl>

``` r
#Paso 2.b Cargar datos de vacaciones desde Prophet
data("dt_prophet_holidays")
head(dt_prophet_holidays)
```

    ## # A tibble: 6 × 4
    ##   ds         holiday                                               country  year
    ##   <date>     <chr>                                                 <chr>   <int>
    ## 1 1995-01-01 Ano Nuevo [New Year's Day]                            AR       1995
    ## 2 1995-02-27 Dia de Carnaval [Carnival's Day]                      AR       1995
    ## 3 1995-02-28 Dia de Carnaval [Carnival's Day]                      AR       1995
    ## 4 1995-03-24 Dia Nacional de la Memoria por la Verdad y la Justic… AR       1995
    ## 5 1995-04-02 Dia del Veterano y de los Caidos en la Guerra de Mal… AR       1995
    ## 6 1995-04-13 Semana Santa (Jueves Santo)  [Holy day (Holy Thursda… AR       1995

``` r
# Exportar resultados al directorio deseado
robyn_object<- "~/MyRobyn.RDS"
```

## Paso 3: Especificación del Modelo

### Paso 3.1 Definir variables de entrada

Dado que Robyn es una herramienta semiautomática, usar una tabla como la
siguiente puede ser valioso para ayudar a articular variables
independientes y de destino para su modelo:

``` r
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
```

    ## Automatically set these variables as 'factor_vars': "events"

    ## Input 'window_start' is adapted to the closest date contained in input data: 2016-01-04

``` r
print(InputCollect)
```

    ## Total Observations: 208 (weeks)
    ## Input Table Columns (12):
    ##   Date: DATE
    ##   Dependent: revenue [revenue]
    ##   Paid Media: tv_S, ooh_S, print_S, facebook_I, search_clicks_P
    ##   Paid Media Spend: tv_S, ooh_S, print_S, facebook_S, search_S
    ##   Context: competitor_sales_B, events
    ##   Organic: newsletter
    ##   Prophet (Auto-generated): trend, season, holiday on DE
    ##   Unused variables: None
    ## 
    ## Date Range: 2015-11-23:2019-11-11
    ## Model Window: 2016-01-04:2018-12-31 (157 weeks)
    ## With Calibration: FALSE
    ## Custom parameters: None
    ## 
    ## Adstock: geometric
    ## Hyper-parameters: [0;31mNot set yet[0m

#### Signo de coeficientes:

Predeterminado: significa que la variable podría tener coeficientes + o
– dependiendo del resultado del modelado. Sin embargo,
Positivo/Negativo: si conoce el impacto específico de una variable de
entrada en la variable objetivo, entonces Puede elegir el signo en
consecuencia. Nota: Todos los controles de signos se proporcionan
automáticamente: “+” para las variables orgánicas y de medios y
“predeterminado” para todas las demás. No obstante, aún puedes
personalizar las señales si es necesario.

#### Paso 3.2 Especificar nombres y rangos de hiperparámetros

Los hiperparámetros de Robyn tienen cuatro componentes:

Parámetro de validación de series temporales (train_size). Parámetros de
Adstock (theta o forma/escala). Parámetros de saturación (alfa/gamma).
Parámetro de regularización (lambda). Especificar nombres de
hiperparámetros

``` r
hyper_names(adstock = InputCollect$adstock, all_media = InputCollect$all_media)
```

    ##  [1] "facebook_S_alphas" "facebook_S_gammas" "facebook_S_thetas"
    ##  [4] "newsletter_alphas" "newsletter_gammas" "newsletter_thetas"
    ##  [7] "ooh_S_alphas"      "ooh_S_gammas"      "ooh_S_thetas"     
    ## [10] "print_S_alphas"    "print_S_gammas"    "print_S_thetas"   
    ## [13] "search_S_alphas"   "search_S_gammas"   "search_S_thetas"  
    ## [16] "tv_S_alphas"       "tv_S_gammas"       "tv_S_thetas"

``` r
## Nota: Establezca plot = TRUE para producir gráficos de ejemplo para
#adstock e hiperparámetros de saturación.

plot_adstock(plot = FALSE)
plot_saturation(plot = FALSE)

# Para comprobar los límites máximos inferior y superior
hyper_limits()
```

    ##   thetas alphas gammas shapes scales
    ## 1    >=0     >0     >0    >=0    >=0
    ## 2     <1    <10    <=1    <20    <=1

``` r
# Especificar rangos de hiperparámetros para material publicitario geométrico
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

#Agregar hiperparámetros a robyn_inputs()

InputCollect <- robyn_inputs(InputCollect = InputCollect, hyperparameters = hyperparameters)
```

    ## >> Running feature engineering...

    ## Warning in .font_global(font, quiet = FALSE): Font 'Arial Narrow' is not
    ## installed, has other name, or can't be found

``` r
print(InputCollect)
```

    ## Total Observations: 208 (weeks)
    ## Input Table Columns (12):
    ##   Date: DATE
    ##   Dependent: revenue [revenue]
    ##   Paid Media: tv_S, ooh_S, print_S, facebook_I, search_clicks_P
    ##   Paid Media Spend: tv_S, ooh_S, print_S, facebook_S, search_S
    ##   Context: competitor_sales_B, events
    ##   Organic: newsletter
    ##   Prophet (Auto-generated): trend, season, holiday on DE
    ##   Unused variables: None
    ## 
    ## Date Range: 2015-11-23:2019-11-11
    ## Model Window: 2016-01-04:2018-12-31 (157 weeks)
    ## With Calibration: FALSE
    ## Custom parameters: None
    ## 
    ## Adstock: geometric
    ## Hyper-parameters ranges:
    ##   facebook_S_alphas: [0.5, 3]
    ##   facebook_S_gammas: [0.3, 1]
    ##   facebook_S_thetas: [0, 0.3]
    ##   print_S_alphas: [0.5, 3]
    ##   print_S_gammas: [0.3, 1]
    ##   print_S_thetas: [0.1, 0.4]
    ##   tv_S_alphas: [0.5, 3]
    ##   tv_S_gammas: [0.3, 1]
    ##   tv_S_thetas: [0.3, 0.8]
    ##   search_S_alphas: [0.5, 3]
    ##   search_S_gammas: [0.3, 1]
    ##   search_S_thetas: [0, 0.3]
    ##   ooh_S_alphas: [0.5, 3]
    ##   ooh_S_gammas: [0.3, 1]
    ##   ooh_S_thetas: [0.1, 0.4]
    ##   newsletter_alphas: [0.5, 3]
    ##   newsletter_gammas: [0.3, 1]
    ##   newsletter_thetas: [0.1, 0.4]
    ##   train_size: [0.5, 0.8]

``` r
##### Guarde InputCollect en el formato de archivo JSON para importarlo más tarde
robyn_write(InputCollect, dir = "./")
```

    ## >> Exported model inputs as ./RobynModel-inputs.json

``` r
InputCollect <- robyn_inputs(
  dt_input = dt_simulated_weekly,
  dt_holidays = dt_prophet_holidays,
  json_file = "./RobynModel-inputs.json")
```

    ## Imported JSON file succesfully: ./RobynModel-inputs.json

    ## >> Running feature engineering...

## Paso 4: Calibración del modelo/Agregar entrada experimental (opcional)

Puede utilizar la función de Calibración de Robyn para aumentar la
confianza al seleccionar su modelo final, especialmente cuando no tiene
información sobre la efectividad y el rendimiento del medio de antemano.
Robyn utiliza estudios de incremento (grupo de prueba versus grupo de
control seleccionado al azar) para comprender la causalidad de su
marketing en las ventas (y otros KPI) y evaluar el impacto incremental
de los anuncios.

``` r
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

    ## Warning in check_calibration(dt_input = InputCollect$dt_input, date_var =
    ## InputCollect$date_var, : Your calibration's spend (421,000) for facebook_S
    ## between 2018-05-01 and 2018-06-10 does not match your dt_input spend (~42.15K).
    ## Please, check again your dates or split your media inputs into separate media
    ## channels.

    ## Warning in check_calibration(dt_input = InputCollect$dt_input, date_var =
    ## InputCollect$date_var, : Your calibration's spend (7,100) for tv_S between
    ## 2018-04-03 and 2018-06-03 does not match your dt_input spend (~2.841K). Please,
    ## check again your dates or split your media inputs into separate media channels.

    ## Warning in check_calibration(dt_input = InputCollect$dt_input, date_var =
    ## InputCollect$date_var, : Your calibration's spend (350,000) for
    ## facebook_S+search_S between 2018-07-01 and 2018-07-20 does not match your
    ## dt_input spend (~67.04K). Please, check again your dates or split your media
    ## inputs into separate media channels.

    ## >> Running feature engineering...

## Paso 5: construcción del modelo

### Paso 5.1 Construir el modelo de referencia

Siempre puede modificar las pruebas y el número de iteraciones según las
necesidades de su negocio para obtener la mayor precisión. Puede
ejecutar ?robyn_run para verificar la definición de parámetros.

``` r
#Construir un modelo inicial

OutputModels <- robyn_run(
  InputCollect = InputCollect,
  cores = NULL,
  iterations = 2000,
  trials = 5,
  ts_validation = TRUE,
  add_penalty_factor = FALSE
)
```

    ## Warning in check_iteration(InputCollect$calibration_input, iterations, trials,
    ## : You are calibrating MMM. We recommend to run at least 2000 iterations per
    ## trial and 10 trials to build initial model

    ## Input data has 208 weeks in total: 2015-11-23 to 2019-11-11

    ## Initial model is built on rolling window of 157 week: 2016-01-04 to 2018-12-31

    ## Time-series validation with train_size range of 50%-80% of the data...

    ## Using geometric adstocking with 20 hyperparameters (20 to iterate + 0 fixed) on 1 core (Windows fallback)

    ## >>> Starting 5 trials with 2000 iterations each with calibration using TwoPointsDE nevergrad algorithm...

    ##   Running trial 1 of 5

    ##   |                                                                              |                                                                      |   0%

    ## Warning: package 'doRNG' was built under R version 4.2.3

    ## Warning: package 'foreach' was built under R version 4.2.2

    ## Warning: package 'rngtools' was built under R version 4.2.2

    ##   |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100% 
    ##   Finished in 6.9 mins

    ##   Running trial 2 of 5

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100% 
    ##   Finished in 6.11 mins

    ##   Running trial 3 of 5

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100% 
    ##   Finished in 6.36 mins

    ##   Running trial 4 of 5

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100% 
    ##   Finished in 6.73 mins

    ##   Running trial 5 of 5

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100% 
    ##   Finished in 6.64 mins

    ## - DECOMP.RSSD NOT converged: sd@qt.20 0.11 > 0.051 & |med@qt.20| 0.57 <= 0.63
    ## - MAPE NOT converged: sd@qt.20 250 > 130 & |med@qt.20| 120 <= 140
    ## - NRMSE NOT converged: sd@qt.20 0.48 > 0.26 & |med@qt.20| 1.2 > 1

    ## Total run time: 33.1 mins

``` r
print(OutputModels)
```

    ## Total trials: 5
    ## Iterations per trial: 2000 (2010 real)
    ## Runtime (minutes): 33.1
    ## Cores: 15
    ## 
    ## Updated Hyper-parameters:
    ##   facebook_S_alphas: [0.5, 3]
    ##   facebook_S_gammas: [0.3, 1]
    ##   facebook_S_thetas: [0, 0.3]
    ##   newsletter_alphas: [0.5, 3]
    ##   newsletter_gammas: [0.3, 1]
    ##   newsletter_thetas: [0.1, 0.4]
    ##   ooh_S_alphas: [0.5, 3]
    ##   ooh_S_gammas: [0.3, 1]
    ##   ooh_S_thetas: [0.1, 0.4]
    ##   print_S_alphas: [0.5, 3]
    ##   print_S_gammas: [0.3, 1]
    ##   print_S_thetas: [0.1, 0.4]
    ##   search_S_alphas: [0.5, 3]
    ##   search_S_gammas: [0.3, 1]
    ##   search_S_thetas: [0, 0.3]
    ##   tv_S_alphas: [0.5, 3]
    ##   tv_S_gammas: [0.3, 1]
    ##   tv_S_thetas: [0.3, 0.8]
    ##   lambda: [0, 1]
    ##   train_size: [0.5, 0.8]
    ## 
    ## Nevergrad Algo: TwoPointsDE
    ## Intercept: TRUE
    ## Intercept sign: non_negative
    ## Time-series validation: TRUE
    ## Penalty factor: FALSE
    ## Refresh: FALSE
    ## 
    ## Convergence on last quantile (iters 1910:2010):
    ##   DECOMP.RSSD NOT converged: sd@qt.20 0.11 > 0.051 & |med@qt.20| 0.57 <= 0.63
    ##   MAPE NOT converged: sd@qt.20 250 > 130 & |med@qt.20| 120 <= 140
    ##   NRMSE NOT converged: sd@qt.20 0.48 > 0.26 & |med@qt.20| 1.2 > 1

### Paso 5.2 Agrupación de soluciones modelo

Robyn utiliza la agrupación K-Means en cada variable de medios (pagos)
para encontrar los “mejores modelos” que tengan NRMSE, DECOM.RSSD y MAPE
(si se utilizó calibrado).

### Paso 5.3 Descomposición de la estacionalidad del profeta

Robyn utiliza Prophet para mejorar el ajuste del modelo y la capacidad
de pronosticar. Si no está seguro de qué líneas base deben incluirse en
el modelado, puede consultar la siguiente descripción:

Tendencia: Movimiento a largo plazo y de evolución lenta (dirección
creciente o decreciente) a lo largo del tiempo. Estacionalidad: Capture
el comportamiento estacional en un ciclo de corto plazo, por ej. anual.
Día laborable: supervise el comportamiento repetitivo semanalmente, si
hay datos diarios disponibles. Día festivo/evento: eventos importantes o
días festivos que tienen un gran impacto en su variable objetivo.

### Paso 5.4 Selección del modelo

Robyn aprovecha MOO de Nevergrad para su paso de selección de modelo al
devolver automáticamente un conjunto de resultados óptimos. Robyn
aprovecha Nevergrad para lograr dos objetivos principales:

Ajuste del modelo: tiene como objetivo minimizar el error de predicción
del modelo, es decir, NRMSE. Business Fit: tiene como objetivo minimizar
la distancia de descomposición, es decir, la distancia de descomposición
raíz cuadrada (DECOMP.RSSD). Esta métrica de distancia es para la
relación entre el porcentaje de gasto y el porcentaje de descomposición
del coeficiente de un canal. Si la distancia es demasiado grande
entonces su resultado puede ser demasiado irreal -Por ej. canal
publicitario con el menor gasto obteniendo el mayor efecto. Entonces
esto parece poco realista. Puede ver en el siguiente cuadro cómo
Nevergrad rechaza el máximo de “modelos malos” (error de predicción
mayor y/o efecto mediático poco realista). Cada punto azul en el gráfico
representa una solución modelo explorada.

### Paso 5.5 Exportar resultados del modelo

## Calcule frentes de Pareto, agrupe y exporte resultados y gráficos.

``` r
OutputCollect <- robyn_outputs(
  InputCollect, OutputModels,
  csv_out = "pareto",
  pareto_fronts = "auto",
  clusters = TRUE,
  export = create_files,
  plot_pareto = create_files,
  plot_folder = robyn_object

)
```

    ## Using robyn object location: C:/Users/jose.lozas.COPPEL/Documents

    ## >>> Running Pareto calculations for 10000 models on auto fronts...

    ## >> Automatically selected 7 Pareto-fronts to contain at least 100 pareto-optimal models (119)

    ## >>> Calculating response curves for all models' media variables (595)...

    ## >> Pareto-Front: 1 [9 models]

    ##  00:00:00 [=====                                    ] 11.1% | 1                       00:00:00 [=========                                ] 22.2% | 2                       00:00:01 [==============                           ] 33.3% | 3                       00:00:01 [==================                       ] 44.4% | 4                       00:00:01 [=======================                  ] 55.6% | 5                       00:00:02 [===========================              ] 66.7% | 6                       00:00:02 [================================         ] 77.8% | 7                       00:00:02 [====================================     ] 88.9% | 8                       00:00:02 [=========================================] 100% | 9

    ## >> Pareto-Front: 2 [13 models]

    ##  00:00:00 [====                                     ] 7.69% | 1                       00:00:00 [=======                                  ] 15.4% | 2                       00:00:01 [==========                               ] 23.1% | 3                       00:00:01 [=============                            ] 30.8% | 4                       00:00:01 [================                         ] 38.5% | 5                       00:00:01 [===================                      ] 46.2% | 6                       00:00:02 [======================                   ] 53.8% | 7                       00:00:02 [=========================                ] 61.5% | 8                       00:00:02 [============================             ] 69.2% | 9                       00:00:03 [===============================          ] 76.9% | 10                      00:00:03 [==================================       ] 84.6% | 11                      00:00:03 [=====================================    ] 92.3% | 12                      00:00:03 [=========================================] 100% | 13

    ## >> Pareto-Front: 3 [20 models]

    ##  00:00:00 [===                                      ] 5% | 1                       00:00:00 [=====                                    ] 10% | 2                       00:00:01 [=======                                  ] 15% | 3                       00:00:01 [=========                                ] 20% | 4                       00:00:01 [===========                              ] 25% | 5                       00:00:01 [=============                            ] 30% | 6                       00:00:02 [===============                          ] 35% | 7                       00:00:02 [=================                        ] 40% | 8                       00:00:02 [===================                      ] 45% | 9                       00:00:03 [=====================                    ] 50% | 10                      00:00:03 [=======================                  ] 55% | 11                      00:00:03 [=========================                ] 60% | 12                      00:00:03 [===========================              ] 65% | 13                      00:00:04 [=============================            ] 70% | 14                      00:00:04 [===============================          ] 75% | 15                      00:00:04 [=================================        ] 80% | 16                      00:00:05 [===================================      ] 85% | 17                      00:00:05 [=====================================    ] 90% | 18                      00:00:05 [=======================================  ] 95% | 19                      00:00:05 [=========================================] 100% | 20

    ## >> Pareto-Front: 4 [17 models]

    ##  00:00:00 [===                                      ] 5.88% | 1                       00:00:00 [=====                                    ] 11.8% | 2                       00:00:01 [========                                 ] 17.6% | 3                       00:00:01 [==========                               ] 23.5% | 4                       00:00:01 [============                             ] 29.4% | 5                       00:00:01 [===============                          ] 35.3% | 6                       00:00:02 [=================                        ] 41.2% | 7                       00:00:02 [===================                      ] 47.1% | 8                       00:00:02 [======================                   ] 52.9% | 9                       00:00:03 [========================                 ] 58.8% | 10                      00:00:03 [==========================               ] 64.7% | 11                      00:00:03 [=============================            ] 70.6% | 12                      00:00:03 [===============================          ] 76.5% | 13                      00:00:04 [=================================        ] 82.4% | 14                      00:00:04 [====================================     ] 88.2% | 15                      00:00:05 [======================================   ] 94.1% | 16                      00:00:05 [=========================================] 100% | 17

    ## >> Pareto-Front: 5 [22 models]

    ##  00:00:00 [==                                       ] 4.55% | 1                       00:00:00 [====                                     ] 9.09% | 2                       00:00:01 [======                                   ] 13.6% | 3                       00:00:01 [========                                 ] 18.2% | 4                       00:00:01 [==========                               ] 22.7% | 5                       00:00:01 [===========                              ] 27.3% | 6                       00:00:02 [=============                            ] 31.8% | 7                       00:00:02 [===============                          ] 36.4% | 8                       00:00:02 [=================                        ] 40.9% | 9                       00:00:03 [===================                      ] 45.5% | 10                      00:00:03 [=====================                    ] 50% | 11                      00:00:03 [======================                   ] 54.5% | 12                      00:00:03 [========================                 ] 59.1% | 13                      00:00:04 [==========================               ] 63.6% | 14                      00:00:04 [============================             ] 68.2% | 15                      00:00:04 [==============================           ] 72.7% | 16                      00:00:05 [===============================          ] 77.3% | 17                      00:00:05 [=================================        ] 81.8% | 18                      00:00:05 [===================================      ] 86.4% | 19                      00:00:05 [=====================================    ] 90.9% | 20                      00:00:06 [=======================================  ] 95.5% | 21                      00:00:06 [=========================================] 100% | 22

    ## >> Pareto-Front: 6 [17 models]

    ##  00:00:00 [===                                      ] 5.88% | 1                       00:00:00 [=====                                    ] 11.8% | 2                       00:00:01 [========                                 ] 17.6% | 3                       00:00:01 [==========                               ] 23.5% | 4                       00:00:01 [============                             ] 29.4% | 5                       00:00:01 [===============                          ] 35.3% | 6                       00:00:02 [=================                        ] 41.2% | 7                       00:00:02 [===================                      ] 47.1% | 8                       00:00:02 [======================                   ] 52.9% | 9                       00:00:03 [========================                 ] 58.8% | 10                      00:00:03 [==========================               ] 64.7% | 11                      00:00:03 [=============================            ] 70.6% | 12                      00:00:03 [===============================          ] 76.5% | 13                      00:00:04 [=================================        ] 82.4% | 14                      00:00:04 [====================================     ] 88.2% | 15                      00:00:04 [======================================   ] 94.1% | 16                      00:00:05 [=========================================] 100% | 17

    ## >> Pareto-Front: 7 [21 models]

    ##  00:00:00 [==                                       ] 4.76% | 1                       00:00:00 [====                                     ] 9.52% | 2                       00:00:01 [======                                   ] 14.3% | 3                       00:00:01 [========                                 ] 19% | 4                       00:00:01 [==========                               ] 23.8% | 5                       00:00:01 [============                             ] 28.6% | 6                       00:00:02 [==============                           ] 33.3% | 7                       00:00:02 [================                         ] 38.1% | 8                       00:00:02 [==================                       ] 42.9% | 9                       00:00:03 [====================                     ] 47.6% | 10                      00:00:03 [=====================                    ] 52.4% | 11                      00:00:03 [=======================                  ] 57.1% | 12                      00:00:03 [=========================                ] 61.9% | 13                      00:00:04 [===========================              ] 66.7% | 14                      00:00:04 [=============================            ] 71.4% | 15                      00:00:04 [===============================          ] 76.2% | 16                      00:00:05 [=================================        ] 81% | 17                      00:00:05 [===================================      ] 85.7% | 18                      00:00:05 [=====================================    ] 90.5% | 19                      00:00:06 [=======================================  ] 95.2% | 20                      00:00:06 [=========================================] 100% | 21

    ## >>> Calculating clusters for model selection using Pareto fronts...

    ## >> Auto selected k = 5 (clusters) based on minimum WSS variance of 5%

    ## >>> Collecting 119 pareto-optimum results into: C:/Users/jose.lozas.COPPEL/Documents/Robyn_202310091148_init/

    ## >> Exporting general plots into directory...

    ## >> Exporting pareto results as CSVs into directory...

    ## >>> Exporting pareto one-pagers into directory...

    ## >> Generating only cluster results one-pagers (5)...

    ## >> Plotting 5 selected models on 15 cores...

    ##   |                                                                              |                                                                      |   0%  |                                                                              |============================                                          |  40%  |                                                                              |==========================================                            |  60%  |                                                                              |========================================================              |  80%  |                                                                              |======================================================================| 100%

    ## >> Exported model inputs as C:/Users/jose.lozas.COPPEL/Documents/Robyn_202310091148_init/RobynModel-inputs.json

``` r
print(OutputCollect)
```

    ## Plot Folder: C:/Users/jose.lozas.COPPEL/Documents/Robyn_202310091148_init/
    ## Calibration Constraint: 0.1
    ## Hyper-parameters fixed: FALSE
    ## Pareto-front (7) All solutions (119): 3_116_4, 3_120_4, 3_121_11, 3_123_13, 3_125_14, 3_127_12, 3_131_3, 3_131_11, 3_133_3, 3_91_4, 3_98_10, 3_101_11, 3_109_11, 3_113_13, 3_114_1, 3_118_4, 3_127_11, 3_128_4, 3_131_4, 3_131_10, 3_133_11, 3_134_4, 3_87_11, 3_89_4, 3_93_11, 3_111_4, 3_111_11, 3_116_15, 3_117_11, 3_118_14, 3_121_4, 3_123_12, 3_124_11, 3_124_15, 3_125_12, 3_130_8, 3_130_9, 3_131_13, 3_133_12, 3_133_13, 3_134_12, 3_134_15, 3_89_11, 3_95_11, 3_100_1, 3_101_8, 3_104_4, 3_104_12, 3_105_3, 3_105_11, 3_106_12, 3_110_14, 3_110_15, 3_113_4, 3_116_5, 3_119_12, 3_121_12, 3_125_8, 3_128_15, 3_96_1, 3_98_4, 3_103_2, 3_104_6, 3_104_10, 3_109_2, 3_112_4, 3_114_4, 3_114_14, 3_116_1, 3_120_6, 3_121_8, 3_121_15, 3_122_15, 3_125_4, 3_125_5, 3_127_5, 3_127_13, 3_129_1, 3_130_4, 3_130_15, 3_133_2, 3_84_1, 3_87_4, 3_106_14, 3_107_1, 3_108_4, 3_109_15, 3_110_11, 3_113_2, 3_113_11, 3_114_15, 3_115_4, 3_119_11, 3_122_9, 3_123_4, 3_123_8, 3_125_13, 3_129_5, 3_85_4, 3_86_1, 3_91_11, 3_92_1, 3_96_4, 3_100_4, 3_102_1, 3_102_5, 3_108_15, 3_109_1, 3_110_6, 3_110_12, 3_111_1, 3_111_3, 3_123_2, 3_123_5, 3_127_4, 3_129_4, 3_129_6, 3_129_8, 3_133_15
    ## Clusters (k = 5): 3_130_15, 3_120_4, 3_108_15, 3_118_14, 3_127_12

## Problema 1

La base de datos `CARS2004` del paquete `PASWR2` recoge el número de
coches por 1000 habitantes (`cars`), el número total de accidentes con
víctimas mortales (`deaths`) y la población/1000 (`population`) para los
25 miembros de la Unión Europea en el año 2004.

1.  Proporciona con `R` resumen de los datos.
2.  Utiliza la función `eda` del paquete `PASWR2` para realizar un
    análisis exploratorio de la variable `deaths`

### Apartado 1

``` r
library(PASWR2)
```

    ## Warning: package 'PASWR2' was built under R version 4.2.3

    ## Loading required package: lattice

``` r
summary(CARS2004) 
```

    ##            country        cars           deaths        population   
    ##  Austria       : 1   Min.   :222.0   Min.   : 33.0   Min.   :  400  
    ##  Belgium       : 1   1st Qu.:354.0   1st Qu.: 72.0   1st Qu.: 3446  
    ##  Cyprus        : 1   Median :448.0   Median :112.0   Median : 8976  
    ##  Czech Republic: 1   Mean   :432.1   Mean   :111.4   Mean   :18273  
    ##  Denmark       : 1   3rd Qu.:491.0   3rd Qu.:135.0   3rd Qu.:16258  
    ##  Estonia       : 1   Max.   :659.0   Max.   :222.0   Max.   :82532  
    ##  (Other)       :19

Como puedes observar, al compilar tu documento aparecen las sentencias
de `R` y el output que te da el programa.

### Apartado 2

Ahora vamos a utilizar la función `eda` del paquete `PASWR2` para
realizar un análisis exploratorio de la variable `deaths`

``` r
eda(CARS2004$deaths)
```

![](20231006MarketingMixModels_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

    ## Size (n)  Missing  Minimum   1st Qu     Mean   Median   TrMean   3rd Qu 
    ##   25.000    0.000   33.000   72.000  111.400  112.000  110.000  135.000 
    ##      Max    Stdev      Var  SE Mean   I.Q.R.    Range Kurtosis Skewness 
    ##  222.000   47.023 2211.167    9.405   63.000  189.000    0.043    0.578 
    ## SW p-val 
    ##    0.243

En este caso, en tu documento final te aparece el código de `R`, el
output numérico de la función `eda` y el output gráfico de la función
`eda`.
