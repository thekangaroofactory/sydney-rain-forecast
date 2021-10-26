

p <- ggplot(eval_df, aes(x = FP.Rate, y = TP.Rate)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  geom_segment(aes(x = 0, y = 0, xend = 1, yend = 1), linetype = "dashed", color = "blue")

print(p)