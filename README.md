# YADR

<!-- badges: start -->
[![R-CMD-check](https://github.com/Appsilon/yadr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Appsilon/yadr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Yet Another Dependency Resolver - `yadr` - is aimed
specifically at dependency resolution for archive versions of packages.

Unlike `pkgdepends` it attempts to respect versions of package dependnecies
that were "latest" at the time of package release - not at the time of
dependency resolution.

## Installation

```R
pak::pak("Appsilon/yadr")
```

## Usage

```R
library(yadr)
dependencies <- yadr::get_solution(package = "rlang", version = "1.0.1")
pkg_refs <- yadr::as_refs(dependencies)
pak::pak(pkg_refs)
```

## Why

Time of writing: February 19th, 2026

### Problem

Let's take an example: I need to install an old version of `rlang` - `1.0.1`,
as well as all of its hard and soft dependencies.

If I wanted to resolve its dependencies recursively via `pkgdepends`, I'd come
by an unsolvable problem:

- `rlang@1.0.1` suggests `testthat`
- `pkgdepends` resolves `testthat` to its latest version
- latest version of `testthat@3.3.2` imports `rlang@1.1.6`
- we have an unsolvable dependency tree

I believe that the core issue here is resolving testthat to its latest version
as of request, not as of the release of `rlang@1.0.1`.

One way to solve this problem is to point `pkgdepends` to a snapshotted CRAN repository,
relevant to the release of `rlang@1.0.1` - for example `https://packagemanager.posit.co/cran/2022-02-05`.

### Solution

`yadr` resolved dependencies in a slightly different way:

- user requests `rlang@1.0.1`
- `yadr` downloads its tarball from CRAN (either from the latest page, or from the archives)
- it then extracts the direct dependencies from DESCRIPTION file using the `desc` package
- then for every direct dependency, it will assign the latest version available before `rlang@1.0.1` release
  - this is achieved again via CRAN archive pages
- then for each versioned direct dependency, `yadr` repeats the same process to obtain respective hard dependencies

Thus, we obtain a complete set of packages required to install an archive version.

### Example

Every code snippet should be executed in a fresh docker container
to avoid any possible environment collisions:

```sh
docker run --rm -ti rocker/r-ver:4.5
```

#### pkgdepends: naive

First, let's see how `pkgdepends` works out of the box:

```R
install.packages("pkgdepends")
library(pkgdepends)

prop <- pkgdepends::new_pkg_installation_proposal(
  refs = "rlang@1.0.1",
  config = list(dependencies = TRUE)
)

prop$solve()$get_solution()
```

You should get something along the lines of

```txt
x failures:
* rlang@1.0.1:
  * Can't install dependency pillar (>= 3.0.0) (>= 0.2.3)
  * Can't install dependency testthat (>= 3.0.0) (>= 0.2.3)
  * Can't install dependency tibble (>= 0.2.3)
  * Can't install dependency usethis (>= 0.2.3)
  * Can't install dependency vctrs (>= 0.2.3)
* pillar: Can't install dependency rlang (>= 1.0.2)
* rlang: Conflicts with rlang@1.0.1
* testthat: Can't install dependency rlang (>= 1.1.6)
* tibble: Can't install dependency rlang (>= 1.0.2)
* usethis: Can't install dependency rlang (>= 1.1.0)
* vctrs: Can't install dependency rlang (>= 1.1.7)
```

... which literally means some dependencies of `rlang` were
resolved to versions clearly requiring a more recent `rlang`
version than we requests. In other words, according to `pkgdepends`
in order to install `rlang@1.0.1` you'd have to install `vctrs`
which in turn imports `rlang@1.1.7`. If you look into the solution
data.frame you'd confirm that the version of `vctrs` corresponds to
what is *currently* the latest version.

#### pkgdepends: CRAN snaphshot

We can solve this problem however by locking the entire CRAN ecosystem
at a point in time:

```R
install.packages("pkgdepends")
library(pkgdepends)

prop <- pkgdepends::new_pkg_installation_proposal(
  refs = "rlang@1.0.1",
  config = list(
    dependencies = TRUE,
    cran_mirror = "https://packagemanager.posit.co/cran/2022-02-07",
    library = tempfile()
  )
)

prop$solve()$get_solution()
```

This works just fine! Clearly, it is not possible to resolve `vctrs` to a version
that requires a more recent version of `rlang` because it simply does not exist
in the repository.

Let's save the results so that we can compare them with what `yadr` resolves:

```R
solution <- prop$solve()$get_solution()
deps <- solution$data[order(solution$data$package), c("package", "version")]
rownames(deps) <- NULL
deps
```

```txt
       package version
1      askpass     1.1
2    base64enc   0.1-3
3         brio   1.1.3
4        callr   3.7.0
5          cli   3.1.1
6        clipr   0.7.1
7         covr   3.5.1
8       crayon   1.4.2
9  credentials   1.3.2
10        curl   4.3.2
11        desc   1.4.0
12     diffobj   0.3.5
13      digest  0.6.29
14    ellipsis   0.3.2
15    evaluate    0.14
16       fansi   1.0.2
17     fastmap   1.1.0
18          fs   1.5.2
19        gert   1.5.0
20          gh   1.3.0
21    gitcreds   0.1.1
22        glue   1.6.1
23       highr     0.9
24   htmltools   0.5.2
25        httr   1.4.2
26         ini   0.3.1
27   jquerylib   0.1.4
28    jsonlite   1.7.3
29       knitr    1.37
30    lazyeval   0.2.2
31   lifecycle   1.0.1
32    magrittr   2.0.2
33        mime    0.12
34     openssl   1.4.6
35      pillar   1.7.0
36   pkgconfig   2.0.3
37     pkgload   1.2.4
38      praise   1.0.0
39    processx   3.5.2
40          ps   1.6.0
41       purrr   0.3.4
42          R6   2.5.1
43    rappdirs   0.3.3
44    rematch2   2.1.2
45         rex   1.2.1
46       rlang   1.0.1
47   rmarkdown    2.11
48   rprojroot   2.0.2
49  rstudioapi    0.13
50     stringi   1.7.6
51     stringr   1.4.0
52         sys     3.4
53    testthat   3.1.2
54      tibble   3.1.6
55     tinytex    0.36
56     usethis   2.1.5
57        utf8   1.2.2
58       vctrs   0.3.8
59       waldo   0.3.1
60     whisker     0.4
61       withr   2.4.3
62        xfun    0.29
63        yaml   2.2.2
64         zip   2.2.0
```

#### yadr

With `yadr` you specify package and version to get a solution from
the official CRAN mirror, without snapshots:

```R
remotes::install_github("Appsilon/yadr")
library(yadr)

solution <- get_solution(
  package = "rlang",
  version = "1.0.1"
)
```

Let's take a look at the result:

```R
deps <- solution[order(solution$package), c("package", "version")]
rownames(deps) <- NULL
deps
```

```txt
       package version
1      askpass     1.1
2    base64enc   0.1-3
3         brio   1.1.3
4        callr   3.7.0
5          cli   3.1.1
6        clipr   0.7.1
7         covr   3.5.1
8       crayon   1.4.2
9  credentials   1.3.2
10        curl   4.3.2
11        desc   1.4.0
12     diffobj   0.3.5
13      digest  0.6.29
14    ellipsis   0.3.2
15    evaluate    0.14
16       fansi   1.0.2
17     fastmap   1.1.0
18          fs   1.5.2
19        gert   1.5.0
20          gh   1.3.0
21    gitcreds   0.1.1
22        glue   1.6.1
23       highr     0.9
24   htmltools   0.5.2
25        httr   1.4.2
26         ini   0.3.1
27   jquerylib   0.1.4
28    jsonlite   1.7.3
29       knitr    1.37
30    lazyeval   0.2.2
31   lifecycle   1.0.1
32    magrittr   2.0.2
33        mime    0.12
34     openssl   1.4.6
35      pillar   1.7.0
36   pkgconfig   2.0.3
37     pkgload   1.2.4
38      praise   1.0.0
39    processx   3.5.2
40          ps   1.6.0
41       purrr   0.3.4
42          R6   2.5.1
43    rappdirs   0.3.3
44    rematch2   2.1.2
45         rex   1.2.1
46       rlang   1.0.1
47   rmarkdown    2.11
48   rprojroot   2.0.2
49  rstudioapi    0.13
50     stringi   1.7.6
51     stringr   1.4.0
52         sys     3.4
53    testthat   3.1.2
54      tibble   3.1.6
55     tinytex    0.36
56     usethis   2.1.5
57        utf8   1.2.2
58       vctrs   0.3.8
59       waldo   0.3.1
60     whisker     0.4
61       withr   2.4.3
62        xfun    0.29
63        yaml   2.2.2
64         zip   2.2.0
```

As we can see, the result is identical to what `pkgdepends` produces from a CRAN
snapshot.
