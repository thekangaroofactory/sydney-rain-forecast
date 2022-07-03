# 
# 
# #predictions <- cbind(formated_data[1:1000, ], raw_predictions[1:1000, ])
# 
# #xxx_predictions$TargetPrediction <- 0
# #xxx_predictions[xxx_predictions$RainTomorrow == "Yes", ]$TargetPrediction <- 1
# 
# library(ggplot2)
# 
# breaks <- as.Date(c("2020-01-01", "2021-01-01", "2022-01-01"))
# 
# 
# # -- Star plot: Polar RawPredictions
# 
# p1 <- ggplot(data = xxx_predictions[xxx_predictions$RainTomorrow == "No", ]) +
#   
#   geom_segment(aes(x = Date, y = 0, xend = Date, yend = RawPrediction, colour = RainTomorrow)) +
#   
#   geom_hline(yintercept = 0.28, linetype = "dashed", color = "grey") +
#   
#   scale_color_discrete(type = c("grey", "#e9b689")) +
#   
#   scale_x_discrete(name = "Date", 
#                    breaks = c("2020-01-01", "2021-01-01", "2022-01-01"), 
#                    labels = c("2020-01-01", "2021-01-01", "2022-01-01")) +
#   
#   coord_polar(theta = "x", start = 0, direction = 1) +
#   
#   theme(axis.title = element_blank(),
#         axis.text = element_blank(),
#         axis.ticks = element_blank(),
#         legend.position = "none")
# 
# 
# # -- Horizontal Spike: RawPredictions
# 
# p2 <- ggplot(data = xxx_predictions) +
#   geom_segment(data = xxx_predictions[xxx_predictions$RainTomorrow == "No", ], aes(x = Date, y = 0, xend = Date, yend = -RawPrediction), color = "grey") +
#   geom_segment(data = xxx_predictions[xxx_predictions$RainTomorrow == "Yes", ], aes(x = Date, y = 0, xend = Date, yend = RawPrediction), color = "#e9b689") +
#   
#   #scale_color_discrete(type = c("grey", "#e9b689")) +
#   
#   geom_hline(yintercept = c(-0.28, 0.28), linetype = "dashed", color = "grey") +
#   
#   geom_vline(xintercept = c("2020-01-01", "2021-01-01", "2022-01-01")) +
#   
#   scale_x_discrete(name = "Date", 
#                    breaks = c("2020-01-01", "2021-01-01", "2022-01-01"), 
#                    labels = c("2020-01-01", "2021-01-01", "2022-01-01")) +
#   
#   
#   theme(axis.text = element_blank(),
#         axis.ticks.x = element_blank(),
#         axis.title = element_blank(),
#         legend.position = "none")
# 
# 
# # --------------------------------------
# p1 <- p1 + theme(
#   panel.background = element_rect(fill = "transparent",
#                                   colour = NA_character_), # necessary to avoid drawing panel outline
#   panel.grid.major = element_blank(), # get rid of major grid
#   #panel.grid.minor = element_blank(), # get rid of minor grid
#   plot.background = element_rect(fill = "transparent",
#                                  colour = NA_character_), # necessary to avoid drawing plot outline
#   #legend.background = element_rect(fill = "transparent"),
#   #legend.box.background = element_rect(fill = "transparent"),
#   #legend.key = element_rect(fill = "transparent")
# )
# 
# p2 <- p2 + theme(
#   panel.background = element_rect(fill = "transparent",
#                                   colour = NA_character_), # necessary to avoid drawing panel outline
#   panel.grid.major = element_blank(), # get rid of major grid
#   panel.grid.minor = element_blank(), # get rid of minor grid
#   plot.background = element_rect(fill = "transparent",
#                                  colour = NA_character_), # necessary to avoid drawing plot outline
#   #legend.background = element_rect(fill = "transparent"),
#   #legend.box.background = element_rect(fill = "transparent"),
#   #legend.key = element_rect(fill = "transparent")
# )
# 
# 
# ggsave(
#   plot = p2,
#   filename = "test_p2.png",
#   bg = "transparent"
# )