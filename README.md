
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SISINTAR

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/INTA-Suelos/SISINTAR/branch/main/graph/badge.svg)](https://codecov.io/gh/INTA-Suelos/SISINTAR?branch=main)
<!-- badges: end -->

El paquete SISINTAR permite descargar, leer y manipular datos de
perfiles de suelo del sistema [SISINTA](http://sisinta.inta.gob.ar/).

## Instalación

Para instalar la versión de desarrollo desde
[GitHub](https://github.com/), usá:

``` r
# install.packages("remotes")
remotes::install_github("INTA-Suelos/SISINTAR", build_vignettes = TRUE)
```

## Algunas características

Para conocer los datos disponibles en SISINTA, la función
`buscar_perfiles()` permite buscar perfiles en función de la
localización, la fecha y la clase o, si se corre sin argumentos,
devolver la lista de perfiles completa. La primera vez que se corre,
descarga el archivo <http://sisinta.inta.gob.ar/es/perfiles.geojson>.

``` r
library(SISINTAR)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

buscar_perfiles() %>% 
  head(10)
#>    perfil_id    numero      fecha
#> 1          1         1 1976-01-01
#> 2          3  13/656 C 1967-03-17
#> 3          4 13/1255 C 1969-10-24
#> 4          6      37 C 1987-08-21
#> 5          7     789 C 1900-01-01
#> 6         18   6/207 C 1965-05-02
#> 7         22      15 C 1990-01-01
#> 8         28  9/1431 C 1969-09-20
#> 9         38 23/1245 C 1989-06-01
#> 10        46        46 1900-01-01
#>                                                    clase       lon       lat
#> 1          Natralbol típico, franca fina, mixta, térmica -61.85000 -34.17250
#> 2                                       Natralbol típico -60.74271 -34.46339
#> 3                       Argiacuol típico, fina, illítica -58.35011 -35.09693
#> 4                         Hapludol éntico, franca gruesa -62.40742 -34.87200
#> 5         Natracualf típico, limosa fina, mixta, térmica -62.20000 -34.10667
#> 6               Argiudol típico, fina, illítica, térmica -59.42444 -33.83333
#> 7                                       Natracuol dúrico -62.80778 -34.45722
#> 8                                     Argiudol abrúptico -58.29163 -35.17931
#> 9           Hapludol típico, franca fina, mixta, térmica -61.93083 -35.78833
#> 10 Argiudol típico, limosa/arcillosa fina,mixta, térmica -61.55278 -33.82500
```

Para descargar lo datos de los perfiles se usa la función
`get_perfiles()`. Ésta toma un vector con los ids de los perfiles a
descargar.

``` r
get_perfiles(c(6653, 6347, 6580)) %>% 
  .[, 1:5] %>% 
  head(10)
#>    analitico_registro analitico_humedad analitico_s analitico_t
#> 1               21711                NA        5.93       19.73
#> 2               21712                NA        5.82       18.22
#> 3                  NA                NA          NA          NA
#> 4                  NA                NA          NA          NA
#> 5                  NA                NA          NA       15.84
#> 6                  NA                NA          NA       15.07
#> 7                  NA                NA          NA       16.10
#> 8                  NA                NA          NA          NA
#> 9               21687                NA        1.49       20.89
#> 10              21688                NA        1.24       18.34
#>    analitico_ph_pasta
#> 1                  NA
#> 2                  NA
#> 3                  NA
#> 4                  NA
#> 5                  NA
#> 6                  NA
#> 7                  NA
#> 8                  NA
#> 9                  NA
#> 10                 NA
```

Alternativamente, puede tomar un data.frame que tenga una columna
llamada “perfil\_id”. Esto es para que se pueda usar directamente la
salida de `buscar_perfiles()` para descargar los perfiles buscados de
acuerdo a cierto criterio.

``` r
buscar_perfiles(rango_fecha = c("2019-01-01", "2019-12-31"),
                clase = c("hapludol", "natralbol")) %>%
  get_perfiles() %>% 
  .[, 1:5] 
#>   analitico_registro analitico_humedad analitico_s analitico_t
#> 1              21711                NA        5.93       19.73
#> 2              21712                NA        5.82       18.22
#> 3                 NA                NA          NA          NA
#>   analitico_ph_pasta
#> 1                 NA
#> 2                 NA
#> 3                 NA
```

También es posible convertir un perfil a un objeto SoilProfileColection
y aprovechar las funcionalides de la librería `aqp`, normalizar perfiles
y exportarlos.

## Cómo contribuir

Para contribuir con este paquete podés leer la siguiente [guía para
contribuir](https://github.com/INTA-Suelos/SISINTAR/blob/main/.github/CONTRIBUTING.md).
Te pedimos también que revises nuestro [Código de
Conducta](https://www.contributor-covenant.org/es/version/2/0/code_of_conduct/code_of_conduct.md).
