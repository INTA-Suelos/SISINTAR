
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
remotes::install_github("INTA-Suelos/SISINTAR")
```

## Algunas características

Para conocer los datos disponibles en SISINTA, la función
`buscar_perfiles()` permite buscar perfiles en función de la
localización, la fecha y la clase o, si se corre sin argumentos,
devolver la lista de perfiles completa.

``` r
library(SISINTAR)

buscar_perfiles() |> 
  head(10)
#>    perfil_id    numero      fecha
#> 1          1         1 1976-01-01
#> 2          3  13/656 C 1967-03-17
#> 3          4 13/1255 C 1969-10-24
#> 4          6      37 C 1987-08-21
#> 5          7     789 C 1976-11-01
#> 6         18   6/207 C 1965-10-07
#> 7         22      15 C 1990-01-01
#> 8         28  9/1431 C 1969-09-20
#> 9         38 23/1245 C 1989-06-01
#> 10        51 25/1944 C 1986-10-28
#>                                             clase             serie       lon
#> 1   Natralbol típico, franca fina, mixta, térmica Aarón Castellanos -61.85000
#> 2                                Natralbol típico      Agustín Roca -60.74271
#> 3                Argiacuol típico, fina, illítica    Alejandro Korn -58.35011
#> 4                  Hapludol éntico, franca gruesa          Ameghino -62.40742
#> 5  Natracualf típico, limosa fina, mixta, térmica          Amenábar -62.19973
#> 6       Argialbol típico, fina, illítica, térmica            Atucha -59.43827
#> 7                                Natracuol dúrico            Balbín -62.80778
#> 8                              Argiudol abrúptico          Brandsen -58.29163
#> 9    Hapludol típico, franca fina, mixta, térmica    Carlos Tejedor -61.93083
#> 10   Argiudol lítico, franca fina, mixta, térmica         Copetonas -60.35188
#>          lat
#> 1  -34.17250
#> 2  -34.46339
#> 3  -35.09693
#> 4  -34.87200
#> 5  -34.10774
#> 6  -33.87714
#> 7  -34.45722
#> 8  -35.17931
#> 9  -35.78833
#> 10 -38.80600
```

Para descargar lo datos de los perfiles se usa la función
`get_perfiles()`. Ésta toma un vector con los ids de los perfiles a
descargar.

``` r
get_perfiles(c(6653, 6347, 6580)) |> 
  subset(select = 1:5) |> 
  head(10)
#>       no_registro eq_humedad sum_bases   cic ph_pasta
#> 23652       21711         NA      5.93 19.73       NA
#> 23653       21712         NA      5.82 18.22       NA
#> 23654          NA         NA        NA    NA       NA
#> 22537          NA         NA        NA    NA       NA
#> 22538          NA         NA        NA 15.84       NA
#> 22539          NA         NA        NA 15.07       NA
#> 22540          NA         NA        NA 16.10       NA
#> 22541          NA         NA        NA    NA       NA
#> 23390       21687         NA      1.49 20.89       NA
#> 23391       21688         NA      1.24 18.34       NA
```

Alternativamente, puede tomar un data.frame que tenga una columna
llamada “perfil_id”. Esto es para que se pueda usar directamente la
salida de `buscar_perfiles()` para descargar los perfiles buscados de
acuerdo a cierto criterio.

``` r
buscar_perfiles(rango_fecha = c("2019-01-01", "2019-12-31"),
                clase = c("hapludol", "natralbol")) |>
  get_perfiles() |> 
  subset(select = 1:5)
#>   no_registro eq_humedad sum_bases   cic ph_pasta
#> 1       21711         NA      5.93 19.73       NA
#> 2       21712         NA      5.82 18.22       NA
#> 3          NA         NA        NA    NA       NA
```

También es posible convertir un perfil a un objeto SoilProfileColection
y aprovechar las funcionalides de la librería `aqp`, normalizar perfiles
y exportarlos.

## Cómo contribuir

Para contribuir con este paquete podés leer la siguiente [guía para
contribuir](https://github.com/INTA-Suelos/SISINTAR/blob/main/.github/CONTRIBUTING.md).
Te pedimos también que revises nuestro [Código de
Conducta](https://www.contributor-covenant.org/es/version/2/0/code_of_conduct/code_of_conduct.md).
