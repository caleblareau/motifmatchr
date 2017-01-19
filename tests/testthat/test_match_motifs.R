context("match_motifs")

data("example_motifs", package = "motifmatchr")

peaks <- GenomicRanges::GRanges(seqnames = c("chr1","chr2","chr2"),
                                ranges = IRanges::IRanges(start = c(76585873,42772928,100183786),
                                                          width = 500))

motif1 = motifmatchr:::convert_pwm(TFBSTools::toPWM(example_motifs[[1]]),
                                   rep(0.25,4))
motif2 = motifmatchr:::convert_pwm(TFBSTools::toPWM(example_motifs[[2]]),
                                   rep(0.25,4))
motif3 = motifmatchr:::convert_pwm(TFBSTools::toPWM(example_motifs[[3]]),
                                   rep(0.25,4))


se <- SummarizedExperiment::SummarizedExperiment(assays = list(counts = matrix(1,
                                                                               ncol = 4,
                                                                               nrow = 3)),
                                                 rowRanges = peaks)

dss <- Biostrings::getSeq(BSgenome.Hsapiens.UCSC.hg19::BSgenome.Hsapiens.UCSC.hg19,
                          peaks)

ch <- as.character(dss)

thresh <-  motifmatchr:::get_thresholds(list(motif1, motif2, motif3), rep(0.25,4), 0.00005)[1:3]

example_pwms <- do.call(TFBSTools::PWMatrixList,lapply(example_motifs, toPWM))

bs_method <- function(motif, s, score){
  forward_matches <- Biostrings::matchPWM(motif, s, min.score = score)
  reverse_matches <- Biostrings::matchPWM(motif, Biostrings::reverseComplement(s), min.score = score)
  (length(forward_matches) !=0) || (length(reverse_matches) != 0)
}

m1 <- sapply(dss, function(x) bs_method(motif1,x, thresh[1]))
m2 <- sapply(dss, function(x) bs_method(motif2,x, thresh[2]))
m3 <- sapply(dss, function(x) bs_method(motif3,x, thresh[3]))

bs_res <- cbind(m1,m2,m3)
colnames(bs_res) <- names(example_motifs)

# Output of matches ------------------------------------------------------------

test_that("Can run match_pwm with PFMatrixList and peaks",{
  mm_res <- match_motifs(example_motifs, peaks, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrixList and SummarizedExperiment",{
  mm_res <- match_motifs(example_motifs, se, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrixList and DNAStringSet",{
  mm_res <- match_motifs(example_motifs, dss, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrixList and character string",{
  mm_res <- match_motifs(example_motifs, ch, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrixList and DNAString",{
  mm_res <- match_motifs(example_motifs, dss[[3]], bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches)[1,], bs_res[3,])
  expect_is(mm_res, "SummarizedExperiment")
})


test_that("Can run match_pwm with PWMatrixList and peaks",{
  mm_res <- match_motifs(example_pwms, peaks, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrixList and SummarizedExperiment",{
  mm_res <- match_motifs(example_pwms, se, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrixList and DNAStringSet",{
  mm_res <- match_motifs(example_pwms, dss, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrixList and character string",{
  mm_res <- match_motifs(example_pwms, ch, bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches), bs_res)
})

test_that("Can run match_pwm with PWMatrixList and DNAString",{
  mm_res <- match_motifs(example_pwms, dss[[3]], bg = rep(0.25,4))
  expect_equal(as.matrix(assays(mm_res)$matches)[1,], bs_res[3,])
})



test_that("Can run match_pwm with PWMatrix and peaks",{
  mm_res <- match_motifs(example_pwms[[3]], peaks, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrix and SummarizedExperiment",{
  mm_res <- match_motifs(example_pwms[[3]], se, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrix and DNAStringSet",{
  mm_res <- match_motifs(example_pwms[[3]], dss, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrix and character string",{
  mm_res <- match_motifs(example_pwms[[3]], ch, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PWMatrix and DNAString",{
  mm_res <- match_motifs(example_pwms[[3]], dss[[3]], bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), unname(bs_res[3,3]))
})


test_that("Can run match_pwm with PFMatrix and peaks",{
  mm_res <- match_motifs(example_motifs[[3]], peaks, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrix and SummarizedExperiment",{
  mm_res <- match_motifs(example_motifs[[3]], se, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrix and DNAStringSet",{
  mm_res <- match_motifs(example_motifs[[3]], dss, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrix and character string",{
  mm_res <- match_motifs(example_motifs[[3]], ch, bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), bs_res[,3])
  expect_is(mm_res, "SummarizedExperiment")
})

test_that("Can run match_pwm with PFMatrix and DNAString",{
  mm_res <- match_motifs(example_motifs[[3]], dss[[3]], bg = rep(0.25,4))
  expect_equal(as.vector(assays(mm_res)$matches), unname(bs_res[3,3]))
})

# Output of scores _------------------------------------------------------------
