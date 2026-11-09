## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse  = TRUE,
  comment   = "#>",
  fig.width = 6,
  fig.height = 4
)

## ----install, eval=FALSE------------------------------------------------------
# install.packages("pigauto")
# packageVersion("pigauto")

## ----install-github, eval=FALSE-----------------------------------------------
# install.packages("pak") # only needed once
# pak::pak("itchyshin/pigauto")

## ----install-torch, eval=FALSE------------------------------------------------
# torch::install_torch()

## ----first-run, eval=FALSE----------------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# 
# traits <- avonet300
# rownames(traits) <- traits$Species_Key
# traits$Species_Key <- NULL
# target <- which(!is.na(traits$Mass))[1L]
# truth <- traits$Mass[target]
# traits$Mass[target] <- NA_real_
# 
# check <- check_pigauto(traits, tree300)
# print(check)
# if (!check$ready) stop("Fix the input problems reported by check_pigauto().")
# result <- impute(traits, tree300, gnn = FALSE)
# completed <- completed_data(result)
# data.frame(
#   species = rownames(traits)[target],
#   measured_mass = truth,
#   imputed_mass = completed$Mass[target]
# )

## ----file-input-route, eval=FALSE---------------------------------------------
# traits <- read_traits("traits.csv", species_col = "species")
# tree <- read_tree("tree.nwk")
# check <- check_pigauto(traits, tree)
# print(check)
# if (identical(check$status, "not_needed")) {
#   message("All matched target cells are observed; no imputation is needed.")
# } else if (identical(check$status, "error")) {
#   stop("Fix the input problems reported by check_pigauto().")
# }

## ----file-input-fit, eval=FALSE-----------------------------------------------
# result <- impute(traits, tree, gnn = FALSE)
# completed <- completed_data(result)
# pigauto_report(result)

## ----declaration-ordinal, eval=FALSE------------------------------------------
# result <- impute(traits, tree, ordinal_levels = list(
#   threat = c("LC", "NT", "VU", "EN", "CR")
# ))
# 
# # Equivalent: construct the ordered factor yourself.
# traits$threat <- ordered(
#   traits$threat,
#   levels = c(
#     "LC", "NT", "VU", "EN", "CR"
#   )
# )
# result <- impute(traits, tree)

## ----declaration-integer-continuous, eval=FALSE-------------------------------
# result <- impute(
#   traits, tree,
#   trait_types = c(
#     length_mm = "continuous"
#   )
# )

## ----declaration-proportion-zi-count, eval=FALSE------------------------------
# result <- impute(
#   traits, tree,
#   trait_types = c(
#     cover = "proportion",
#     parasites = "zi_count"
#   )
# )

## ----declaration-composition, eval=FALSE--------------------------------------
# result <- impute(
#   traits, tree,
#   multi_proportion_groups = list(
#     diet = c(
#       "diet_insect",
#       "diet_fruit",
#       "diet_seed"
#     )
#   )
# )

## ----load---------------------------------------------------------------------
library(pigauto)
library(ape)

## ----quickstart, eval=FALSE---------------------------------------------------
# result <- impute(traits, tree)
# 
# result$completed    # observed values preserved; some missing values may remain NA
# result$imputed_mask # TRUE marks missing targets in fitted rows, not successful fills
# result$prediction$se # per-cell, type-dependent uncertainty summaries

## ----data---------------------------------------------------------------------
data(avonet300, tree300, package = "pigauto")

head(avonet300)
ape::Ntip(tree300)

## ----preprocess---------------------------------------------------------------
traits <- avonet300[, -1]              # drop Species_Key column
rownames(traits) <- avonet300$Species_Key

pd <- preprocess_traits(traits, tree300, log_transform = TRUE)
print(pd)

## ----splits-------------------------------------------------------------------
splits <- make_missing_splits(pd$X_scaled, missing_frac = 0.25, seed = 42,
                              trait_map = pd$trait_map)

cat("Held-out latent cells:", length(splits$val_idx) + length(splits$test_idx), "\n")
cat("  Validation:", length(splits$val_idx), "\n")
cat("  Test:      ", length(splits$test_idx), "\n")

## ----baseline, eval=TRUE------------------------------------------------------
baseline <- fit_baseline(pd, tree300, splits = splits, model = "BM")

cat("Baseline object contains:\n")
cat("  mu matrix:", nrow(baseline$mu), "x", ncol(baseline$mu), "\n")
cat("  se matrix:", nrow(baseline$se), "x", ncol(baseline$se), "\n")

## ----graph, eval=TRUE---------------------------------------------------------
graph <- build_phylo_graph(
  tree300,
  k_eigen    = 8,
  sigma_mult = 0.5
)

cat("Graph: n =", graph$n, "species\n")
cat("Adjacency: [", nrow(graph$adj), "x", ncol(graph$adj), "]\n")
cat("Spectral coords: [", nrow(graph$coords), "x", ncol(graph$coords), "]\n")
cat("Kernel bandwidth sigma:", round(graph$sigma, 3), "\n")

## ----train, eval=FALSE--------------------------------------------------------
# fit <- fit_pigauto(
#   data            = pd,
#   tree            = tree300,
#   splits          = splits,
#   graph           = graph,
#   baseline        = baseline,
#   hidden_dim      = 64,
#   k_eigen         = 8,
#   dropout         = 0.10,
#   lr              = 3e-3,
#   epochs          = 2000,
#   corruption_rate = 0.55,
#   lambda_shrink   = 0.03,
#   eval_every      = 100,
#   patience        = 10,
#   verbose         = TRUE,
#   seed            = 1,
#   gnn             = TRUE
# )

## ----print-fit, eval=FALSE----------------------------------------------------
# print(fit)

## ----predict, eval=FALSE------------------------------------------------------
# pred <- predict(fit, return_se = TRUE)
# 
# # pred$imputed: 300-row data.frame with the 7 original trait columns
# # pred$imputed_latent: 300 x 14 matrix on the latent scale
# # pred$se: 300 x 7 per-trait uncertainty matrix
# head(pred$imputed)
# 
# # Conformal prediction intervals (nominal held-out diagnostic)
# pred$conformal_lower[, "Mass"]    # lower bound per species (original units)
# pred$conformal_upper[, "Mass"]    # upper bound per species (original units)
# # Coverage is not stored on the prediction object. Score it with evaluate()
# # (or evaluate_imputation() on held-out cells).

## ----evaluate, eval=FALSE-----------------------------------------------------
# # Held-out scores (z-score RMSE for continuous traits)
# # Mask validation/test cells before scoring; plain predict() is for imputation.
# pred_eval <- predict(fit, evaluation = TRUE)
# evaluate_imputation(pred_eval, pd$X_scaled, splits)
# 
# # Per-trait calibrated gate. 0 means baseline-only.
# fit$r_cal

## ----plot-history, eval=FALSE-------------------------------------------------
# plot(fit, type = "history")

## ----plot-uncertainty, eval=FALSE---------------------------------------------
# plot(pred, type = "intervals", trait = "Mass")

## ----mi-workflow, eval=FALSE--------------------------------------------------
# analysis_data$z_sq <- analysis_data$z^2
# 
# mi <- multi_impute_analysis(
#   data = analysis_data,
#   formula = y ~ x + z,
#   missing = "x",
#   model = "lm",
#   m = 50L,
#   auxiliary = "z_sq",
#   seed = 1L
# )
# 
# fits <- with_imputations(mi, function(d) lm(y ~ x + z, data = d))
# pool_mi(fits)

## ----active-impute, eval=FALSE------------------------------------------------
# res <- impute(traits, tree300)
# 
# # Top-10 individual (species, trait) cells, ordered by expected
# # total variance reduction:
# suggest_next_observation(res, top_n = 10, by = "cell")
# 
# # Or aggregated by species (sum of variance reductions across the
# # species' currently-missing continuous-family traits):
# suggest_next_observation(res, top_n = 10, by = "species")

## ----advanced-controls, eval=FALSE--------------------------------------------
# result <- impute(
#   traits, tree,
#   joint_solver = "rphylopars",
#   em_iterations = 2L,
#   joint_refine_iter = 1L,
#   conformal_split_val = TRUE
# )

## ----exact-route, eval=FALSE--------------------------------------------------
# result <- impute(traits, tree, predict_method = "exact")

## ----phylo-signal-gate, eval=FALSE--------------------------------------------
# result <- impute(traits, tree,
#                  phylo_signal_gate     = TRUE,   # opt-in (default FALSE)
#                  safety_floor          = TRUE,   # enables the grand-mean fallback
#                  phylo_signal_threshold = 0.2,   # default; min lambda to keep BM/GNN
#                  phylo_signal_method   = "lambda")

## ----phylo-signal-gate-off, eval=FALSE----------------------------------------
# result <- impute(traits, tree, phylo_signal_gate = FALSE)

## ----covariate-helpers, eval=FALSE--------------------------------------------
# # Step 1: GBIF occurrence centroids (median lat/lon across cleaned points)
# gbif <- pull_gbif_centroids(species          = rownames(my_traits),
#                             cache_dir        = "cache/gbif",
#                             occurrence_limit = 500L,
#                             store_points     = TRUE,
#                             refresh_cache    = TRUE)
# #> data.frame with columns species, centroid_lat, centroid_lon, n_occurrences
# 
# # Step 2: WorldClim bioclim summaries (median + IQR of all 19 bio variables
# # across each species' GBIF occurrences)
# clim <- pull_worldclim_per_species(species             = rownames(my_traits),
#                                     gbif_cache_dir      = "cache/gbif",
#                                     worldclim_cache_dir = "cache/worldclim",
#                                     resolution          = "10m",
#                                     refresh_cache       = TRUE)
# #> data.frame with bio1..bio19 medians + IQRs + n_extracted per species
# 
# # Check the species order before fitting: covariate rows must match trait rows.
# stopifnot(identical(clim$species, rownames(my_traits)))
# 
# # Step 3: keep the intended numeric climate summaries, not species or count
# climate_cols <- grep("^bio[0-9]+_(median|iqr)$", names(clim), value = TRUE)
# clim_cov <- clim[, climate_cols, drop = FALSE]
# if (anyNA(clim_cov)) stop("Resolve missing climate values before fitting")
# result <- impute(my_traits, my_tree, covariates = clim_cov, gnn = TRUE)

## ----gpu, eval=FALSE----------------------------------------------------------
# torch::cuda_is_available()       # NVIDIA GPU
# torch::backends_mps_is_available() # Apple Silicon GPU

## ----cache, eval=FALSE--------------------------------------------------------
# graph <- build_phylo_graph(tree300, k_eigen = 8, cache_path = "tree300_graph.rds")

## ----own-data, eval=FALSE-----------------------------------------------------
# tree   <- ape::read.tree("my_phylogeny.nwk")
# traits <- read_traits("my_traits.csv", species_col = "species")
# pd     <- preprocess_traits(traits, tree)
# # ...proceed as above

