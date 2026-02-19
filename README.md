# YADR

<!-- badges: start -->
[![R-CMD-check](https://github.com/Appsilon/yadr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Appsilon/yadr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Yet Another Dependency Resolver

## Installation

```R
remotes::install_github("Appsilon/yadr")
```

## Usage

```R
library(yadr)
dependencies <- yadr::get_tree(package = "rlang", version = "1.0.1")
pkg_refs <- yadr::make_refs(dependencies)
pak::pak(pkg_refs)
```
