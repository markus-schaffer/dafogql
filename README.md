# dafogql

<!-- badges: start -->
[![R-CMD-check](https://github.com/markus-schaffer/dafogql/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/markus-schaffer/dafogql/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`dafogql` is an R package that provides functions to query the GraphQL APIs of [Datafordeler](https://datafordeler.dk/) for the **BBR** (Bygnings- og Boligregistret), **DAR** (Danmarks Adresseregister), and **MAT** (Matriklen).

## Installation

You can install the development version from GitHub:

```r
# Install remotes if needed
install.packages("remotes")

# Install from GitHub
remotes::install_github("markus-schaffer/dafogql")
```

## Features

The package covers the following Datafordeler entities:

- **BBR** – `bbr_bygning()`, `bbr_enhed()`, `bbr_ejendomsrelation()`, `bbr_ejendomsrelation_kommune()`
- **DAR** – `dar_adress()`, `dar_adressepunkt()`, `dar_husnummer()`
- **MAT** – `mat_jordstykke()`, `mat_jordstykke2()`

## Authentication

The package uses OAuth 2.0 to authenticate against the Datafordeler API. Use `build_oauth_client()` to set up your credentials before making requests.

To set these up, first create a user at Datafordeler here: <https://portal.datafordeler.dk/hjem>
Afterwards, set up an "IT system" and then create an OAuth Shared Secret.

## Dependencies

- R (>= 4.1.0)
- stats
- [`httr2`](https://httr2.r-lib.org/)
- [`jsonlite`](https://jeroen.r-universe.dev/jsonlite)

## License

GPL (>= 3)
