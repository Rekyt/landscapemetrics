## Update Version: 0.1.1

a) The Solaris installation error is described in §1.6.4 of 'Writing R 
Extensions': please study it.

* Done as suggested

b) You use isFALSE from R 3.5.x despite claiming Depends: R (≥ 3.1): you 
cannot have actually tested that.

* Done as suggested

c) There are problems with the tests showing in the 'Additional issues' (shortly if not already).  
The way you write your tests, the reports such as

── 1. Failure: lsm_c_lsi results are equal to fragstats (@test-lsm-c-lsi.R#7)  ─
 all(...) isn't true.

 ── 2. Failure: lsm_c_split results are equal to fragstats (@test-lsm-c-split.R#7
 all(...) isn't true.

 ── 3. Failure: lsm_p_enn results are comparable to fragstats (@test-lsm-p-enn.R#
 all(...) isn't true.

are completely useless. But testing numerical results by rounding rather than using all.equal 
is bad practice (and it is not you who is paying the price!).

You could use something like

> all.equal(sort(fragstats_class_landscape_lsi), sort(landscapemetrics_class_landscape_lsi$value))
[1] "Mean relative difference: 4.816766e-06"

with a suitable tolerance.

* The software we compare our results to (FRAGSTATS) has only a precision of 4 digits itself. We discussed using relative differences but decided that we do not want to show that our results are equal to the FRAGSTATS results within a tolerance, but rather that our results would be exactly the same assuming the same precision. Therefore we decided to round our results for the tests.


## Test environments
* local OS X install, R 3.5.1
* ubuntu 18.04, R 3.5.1
* macOS High Sierra, R 3.5.1
* ubuntu 14.04 (on travis-ci), R 3.5.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

## Reverse dependencies

There are currently no reverse dependencies.
