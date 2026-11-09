## ----setup, message=FALSE-----------------------------------------------------
library(pigauto)
data(avonet300, tree300)
tree <- ape::keep.tip(tree300, tree300$tip.label[seq_len(30)])
traits <- avonet300[match(tree$tip.label, avonet300$Species_Key),
                    c("Mass", "Wing.Length"), drop = FALSE]
rownames(traits) <- tree$tip.label
traits$Mass[1:5] <- NA
traits$Wing.Length[4:8] <- NA
x <- preprocess_traits(traits, tree)

## ----fig.height=6, fig.width=8, out.width="100%"------------------------------
plot_missingness(x, "summary")
plot_missingness(x, "matrix")

## ----fig.height=6, fig.width=8, out.width="100%"------------------------------
plot_missingness(x, "phylo", tree)
plot_missingness(x, "co_missing")

## ----fit-plots, message=FALSE, warning=FALSE, fig.width=8, fig.height=5-------
result <- impute(traits, tree, gnn = FALSE, verbose = FALSE, seed = 7)
plot(result$fit, type = "conformal")
evaluate(result$fit)

