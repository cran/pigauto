## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width  = 6,
  fig.height = 4
)

## ----section1-diag, eval = FALSE----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300
# rownames(df) <- df$Species_Key
# df$Species_Key <- NULL
# sum(is.na(df))                  # if 0, there's nothing for impute() to do

## ----section1-fix, eval = FALSE-----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300
# rownames(df) <- df$Species_Key
# df$Species_Key <- NULL
# 
# set.seed(1L)
# n_hide <- min(30L, sum(!is.na(df$Mass)))
# if (n_hide == 0L) stop("No observed Mass values are available to hide.")
# hide   <- sample(which(!is.na(df$Mass)), n_hide)
# df_obs <- df
# df_obs$Mass[hide] <- NA          # hide up to 30 mass values
# 
# result <- impute(df_obs, tree300)
# 
# result$completed$Mass[hide]      # pigauto's imputations
# df$Mass[hide]                    # held-out truth, for comparison
# sum(result$imputed_mask[, "Mass"])  # number of values hidden above

## ----eval=FALSE---------------------------------------------------------------
# mask <- result$imputed_mask
# imputed_values <- lapply(colnames(mask), function(nm) {
#   result$completed[[nm]][mask[, nm]]
# })
# names(imputed_values) <- colnames(mask)

## ----section2-diag, eval = FALSE----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300; rownames(df) <- df$Species_Key; df$Species_Key <- NULL
# 
# table(df$Migration)              # check the marginal distribution
# hide <- sample(which(!is.na(df$Migration)), 30L)
# df$Migration[hide] <- NA
# result <- impute(df, tree300, verbose = FALSE)
# table(result$completed$Migration[hide])

## ----section2-fix, eval = FALSE-----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300; rownames(df) <- df$Species_Key; df$Species_Key <- NULL
# 
# set.seed(1L)
# n_hide <- min(30L, sum(!is.na(df$Migration)))
# if (n_hide == 0L) stop("No observed Migration values are available to hide.")
# hide   <- sample(which(!is.na(df$Migration)), n_hide)
# df_obs <- df
# df_obs$Migration[hide] <- NA
# 
# # Default settings: prone to majority-class collapse on imbalanced K = 3
# result <- impute(df_obs, tree300, verbose = FALSE)
# table(result$completed$Migration[hide], df$Migration[hide])
# 
# # Candidate for K = 3 ordinal: more draws + mode pooling
# result_mode <- impute(df_obs, tree300, n_imputations = 20L,
#                       pool_method = "mode", verbose = FALSE)
# table(result_mode$completed$Migration[hide], df$Migration[hide])

## ----section3-diag, eval = FALSE----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300; rownames(df) <- df$Species_Key; df$Species_Key <- NULL
# set.seed(1L)
# hide <- sample(which(!is.na(df$Migration)), 30L)
# df_obs <- df
# df_obs$Migration[hide] <- NA
# fit <- impute(df_obs, tree300, gnn = TRUE, verbose = FALSE)$fit
# 
# # Per-latent-column calibrated gates:
# fit$r_cal_bm        # r assigned to the BM baseline
# fit$r_cal_gnn       # r assigned to the GNN delta
# fit$r_cal_mean      # r assigned to the grand mean

## ----section4-diag, eval = FALSE----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300; rownames(df) <- df$Species_Key; df$Species_Key <- NULL
# 
# set.seed(1L)
# hide <- sample(which(!is.na(df$Mass)), 30L)
# df_obs <- df
# df_obs$Mass[hide] <- NA
# fit <- impute(df_obs, tree300, phylo_signal_gate = TRUE)$fit
# fit$phylo_signal_per_trait

## ----section5-diag, eval = FALSE----------------------------------------------
# # After running impute(), check whether any imputation exceeds the
# # observed maximum by an unrealistic factor:
# predicted_mass <- result$completed$Mass[result$imputed_mask[, "Mass"]]
# obs_max <- max(df$Mass, na.rm = TRUE)
# sum(predicted_mass > 5 * obs_max)

## ----section5-fix, eval = FALSE-----------------------------------------------
# library(pigauto)
# data(avonet300, tree300)
# df <- avonet300; rownames(df) <- df$Species_Key; df$Species_Key <- NULL
# set.seed(1L)
# n_hide <- min(30L, sum(!is.na(df$Mass)))
# if (n_hide == 0L) stop("No observed Mass values are available to hide.")
# hide <- sample(which(!is.na(df$Mass)), n_hide)
# df_obs <- df
# df_obs$Mass[hide] <- NA
# 
# result <- impute(df_obs, tree300,
#                  clamp_outliers = TRUE,
#                  clamp_factor   = 5,
#                  verbose = FALSE)

