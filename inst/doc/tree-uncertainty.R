## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = requireNamespace("torch", quietly = TRUE) &&
         isTRUE(try(torch::torch_is_installed(), silent = TRUE))
)

## ----birdtree-download, eval = FALSE------------------------------------------
# install.packages("megatrees")
# bird_trees <- megatrees::get_tree_bird_n100()

## ----canonical-align, eval = FALSE--------------------------------------------
# library(pigauto)
# data(avonet300, trees300)
# # Work on a copy; keep the original measurements unchanged.
# df <- avonet300
# # Move the species-name column to row names. Skip these two lines if your
# # species names are already the row names of your data frame.
# rownames(df) <- df$Species_Key
# df$Species_Key <- NULL
# 
# # Set FALSE for trees with different tip sets. The default shared-reference
# # route below uses a simple common-tip-set check.
# share_gnn <- TRUE
# if (share_gnn) {
#   tip_names <- trees300[[1L]]$tip.label
#   common_tip_set <- vapply(trees300, function(tree) {
#     setequal(tree$tip.label, tip_names)
#   }, logical(1))
#   stopifnot(all(common_tip_set))
# }
# # Score only species represented in every tree; extra tree-only tips are okay.
# common_species <- Reduce(intersect, lapply(trees300, function(tree) {
#   tree$tip.label
# }))
# scoreable_rows <- which(!is.na(df$Mass) & rownames(df) %in% common_species)
# n_test <- 10L
# if (length(scoreable_rows) < n_test) {
#   stop("Choose n_test no larger than the number of observed values for ",
#        "species present in every tree.")
# }
# 
# set.seed(2026L)
# # Select measured values so predictions can be checked against their truth.
# target_rows <- scoreable_rows[sample.int(length(scoreable_rows), n_test)]
# mass_truth <- df$Mass[target_rows]
# # Hide only these selected cells. Naturally missing values stay missing and
# # cannot be scored because their true values are unknown.
# df$Mass[target_rows] <- NA_real_

## ----canonical-predict, eval = FALSE------------------------------------------
# mi <- multi_impute_trees(
#   df, trees = trees300, share_gnn = share_gnn, gnn = FALSE,
#   m_per_tree = 1L, seed = 2026L
# )

## ----canonical-summarise, eval = FALSE----------------------------------------
# mass_by_tree <- vapply(mi$datasets, function(dat) dat$Mass, numeric(nrow(df)))
# heldout_predictions <- mass_by_tree[target_rows, , drop = FALSE]
# finite_predictions <- is.finite(heldout_predictions)
# trees_with_prediction <- rowSums(finite_predictions)
# heldout_predictions[!finite_predictions] <- NA_real_
# mean_prediction <- rowMeans(heldout_predictions, na.rm = TRUE)
# mean_prediction[trees_with_prediction == 0L] <- NA_real_
# prediction_error <- mean_prediction - mass_truth
# tree_sensitivity_sd <- apply(heldout_predictions, 1L, function(x) {
#   x <- x[is.finite(x)]
#   if (length(x) < 2L) NA_real_ else stats::sd(x)
# })
# usable <- is.finite(prediction_error)
# data.frame(
#   species = rownames(df)[target_rows],
#   observed_truth = mass_truth,
#   trees_with_prediction = trees_with_prediction,
#   mean_prediction = mean_prediction,
#   absolute_error = abs(prediction_error),
#   tree_sensitivity_sd = tree_sensitivity_sd
# )
# if (any(usable)) {
#   c(
#     usable_species = sum(usable),
#     excluded_species = sum(!usable),
#     RMSE = sqrt(mean(prediction_error[usable]^2)),
#     MAE = mean(abs(prediction_error[usable]))
#   )
# } else {
#   message("No held-out predictions were available; RMSE and MAE are not computed.")
# }

## ----opt_out, eval = FALSE----------------------------------------------------
# mi_slow <- multi_impute_trees(df, trees300, m_per_tree = 1L,
#                                gnn = TRUE, share_gnn = FALSE)
# # Fits a separate GNN on each tree; runtime depends on tree size and hardware.

