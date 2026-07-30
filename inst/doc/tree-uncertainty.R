## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = requireNamespace("torch", quietly = TRUE) &&
         isTRUE(try(torch::torch_is_installed(), silent = TRUE))
)

## ----canonical, eval = FALSE--------------------------------------------------
# library(pigauto)
# data(avonet300, trees300)
# df <- avonet300
# rownames(df) <- df$Species_Key
# df$Species_Key <- NULL
# 
# mi <- multi_impute_trees(df, trees = trees300, m_per_tree = 1L)
# # share_gnn = TRUE, reference_tree = MCC via phangorn -- all default
# 
# mass_by_tree <- vapply(mi$datasets, function(dat) dat$Mass, numeric(nrow(df)))
# apply(mass_by_tree, 1L, stats::sd)  # descriptive sensitivity, not an MI SE

## ----opt_out, eval = FALSE----------------------------------------------------
# mi_slow <- multi_impute_trees(df, trees300, m_per_tree = 1L,
#                                share_gnn = FALSE)
# # fits T = length(trees300) full pigauto models -- ~10-15x slower.

