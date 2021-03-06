% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/distance-methods.R
\docType{methods}
\name{UniFrac}
\alias{UniFrac}
\alias{UniFrac,phyloseq-method}
\title{Calculate weighted or unweighted (Fast) UniFrac distance for all sample pairs.}
\usage{
UniFrac(physeq, weighted=FALSE, normalized=TRUE, parallel=FALSE, fast=TRUE)

\S4method{UniFrac}{phyloseq}(physeq, weighted = FALSE, normalized = TRUE,
  parallel = FALSE, fast = TRUE)
}
\arguments{
\item{physeq}{(Required). \code{\link{phyloseq-class}}, containing at minimum
a phylogenetic tree (\code{\link{phylo-class}}) and 
contingency table (\code{\link{otu_table-class}}). See
examples below for coercions that might be necessary.}

\item{weighted}{(Optional). Logical. Should use weighted-UniFrac calculation?
Weighted-UniFrac takes into account the relative abundance of species/taxa
shared between samples, whereas unweighted-UniFrac only considers 
presence/absence. Default is \code{FALSE}, meaning the unweighted-UniFrac
distance is calculated for all pairs of samples.}

\item{normalized}{(Optional). Logical. Should the output be normalized such that values 
range from 0 to 1 independent of branch length values? Default is \code{TRUE}.
Note that (unweighted) \code{UniFrac} is always normalized by total branch-length,
and so this value is ignored when \code{weighted == FALSE}.}

\item{parallel}{(Optional). Logical. Should execute calculation in parallel,
using multiple CPU cores simultaneously? This can dramatically hasten the
computation time for this function. However, it also requires that the user
has registered a parallel ``backend'' prior to calling this function. 
Default is \code{FALSE}. If FALSE, UniFrac will register a serial backend
so that \code{foreach::\%dopar\%} does not throw a warning.}

\item{fast}{(Optional). Logical. DEPRECATED.
Do you want to use the ``Fast UniFrac''
algorithm? Implemented natively in the \code{phyloseq-package}.
\code{TRUE} is now the only supported option.
There should be no difference in the output between the two algorithms.
Moreover, the original UniFrac algorithm
only outperforms this implementation of fast-UniFrac if the datasets are so
small 
(approximated by the value of \code{ntaxa(physeq) * nsamples(physeq)}) 
that the difference in time is inconsequential (less than 1 second).
In practice it does not appear that this parameter should 
have ever been set to \code{FALSE}, and therefore 
the original UniFrac implementation perhaps never should have been supported here.
For legacy code support the option is now deprecated here
(the implementation was an internal function, anyway)
and the \code{fast} option will remain for one release cycle before
being removed completely
in order to avoid causing unsupported-argument errors.}
}
\value{
a sample-by-sample distance matrix, suitable for NMDS, etc.
}
\description{
This function calculates the (Fast) UniFrac distance for all sample-pairs
in a \code{\link{phyloseq-class}} object.
}
\details{
\code{UniFrac()} accesses the abundance
(\code{\link{otu_table-class}}) and a phylogenetic tree (\code{\link{phylo-class}})
data within an experiment-level (\code{\link{phyloseq-class}}) object.
If the tree and contingency table are separate objects, suggested solution
is to combine them into an experiment-level class
using the \code{\link{phyloseq}} function. For example, the following code

\code{phyloseq(myotu_table, myTree)}

returns a \code{phyloseq}-class object that has been pruned and comprises
the minimum arguments necessary for \code{UniFrac()}.

Parallelization is possible for UniFrac calculated with the \code{\link{phyloseq-package}},
and is encouraged in the instances of large trees, many samples, or both.
Parallelization has been implemented via the \code{\link{foreach-package}}.
This means that parallel calls need to be preceded by 2 or more commands
that register the parallel ``backend''. This is acheived via your choice of
helper packages. One of the simplest seems to be the \emph{doParallel} package.

For more information, see the following links on registering the ``backend'':

\emph{foreach} package manual:

\url{http://cran.r-project.org/web/packages/foreach/index.html}

Notes on parallel computing in \code{R}. Skip to the section describing 
the \emph{foreach Framework}. It gives off-the-shelf examples for registering
a parallel backend using the \emph{doMC}, \emph{doSNOW}, or \emph{doMPI} packages:

\url{http://trg.apbionet.org/euasiagrid/docs/parallelR.notes.pdf}

Furthermore, as of \code{R} version \code{2.14.0} and higher, a parallel package
is included as part of the core installation, \code{\link{parallel-package}}, 
and this can be used as the parallel backend with the \code{\link{foreach-package}}
using the adaptor package ``doParallel''. 
\url{http://cran.r-project.org/web/packages/doParallel/index.html}

See the vignette for some simple examples for using doParallel.
\url{http://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf}

UniFrac-specific examples for doParallel are provided in the example
code below.
}
\examples{
################################################################################
# Perform UniFrac on esophagus data
################################################################################
data("esophagus")
(y <- UniFrac(esophagus, TRUE))
UniFrac(esophagus, TRUE, FALSE)
UniFrac(esophagus, FALSE)
# ################################################################################
# # Now try a parallel implementation using doParallel, which leverages the 
# # new 'parallel' core package in R 2.14.0+
# # Note that simply loading the 'doParallel' package is not enough, you must
# # call a function that registers the backend. In general, this is pretty easy
# # with the 'doParallel package' (or one of the alternative 'do*' packages)
# #
# # Also note that the esophagus example has only 3 samples, and a relatively small
# # tree. This is fast to calculate even sequentially and does not warrant
# # parallelized computation, but provides a good quick example for using UniFrac()
# # in a parallel fashion. The number of cores you should specify during the
# # backend registration, using registerDoParallel(), depends on your system and
# # needs. 3 is chosen here for convenience. If your system has only 2 cores, this
# # will probably fault or run slower than necessary.
# ################################################################################
# library(doParallel)
# data(esophagus)
# # For SNOW-like functionality (works on Windows):
# cl <- makeCluster(3)
# registerDoParallel(cl)
# UniFrac(esophagus, TRUE)
# # Force to sequential backed:
# registerDoSEQ()
# # For multicore-like functionality (will probably not work on windows),
# # register the backend like this:
# registerDoParallel(cores=3)
# UniFrac(esophagus, TRUE)
################################################################################
}
\references{
\url{http://bmf.colorado.edu/unifrac/}

The main implementation (Fast UniFrac) is adapted from the algorithm's
description in:

Hamady, Lozupone, and Knight,
``\href{http://www.nature.com/ismej/journal/v4/n1/full/ismej200997a.html}{Fast UniFrac:}
facilitating high-throughput phylogenetic analyses of 
microbial communities including analysis of pyrosequencing and PhyloChip data.''
The ISME Journal (2010) 4, 17--27.

See also additional descriptions of UniFrac in the following articles:

Lozupone, Hamady and Knight, ``UniFrac - An Online Tool for Comparing Microbial 
Community Diversity in a Phylogenetic Context.'', BMC Bioinformatics 2006, 7:371

Lozupone, Hamady, Kelley and Knight, ``Quantitative and qualitative (beta) 
diversity measures lead to different insights into factors that structure
microbial communities.'' Appl Environ Microbiol. 2007

Lozupone C, Knight R. ``UniFrac: a new phylogenetic method for comparing microbial
communities.'' Appl Environ Microbiol. 2005 71 (12):8228-35.
}
\seealso{
\code{\link{distance}}

\code{unifrac} in the picante package.
}
