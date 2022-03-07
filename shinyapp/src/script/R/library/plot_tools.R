

# ------------------------------------------------------------------------------
# PLOT TOOLS
# ------------------------------------------------------------------------------

# -- Plot: a single boxPlot to show distribution of values
plot.singleBox <- function(data, col)
{
  p <- ggplot(data, aes_string(y = col)) + 
    geom_boxplot(outlier.colour = "red", outlier.shape = 3, outlier.size = 1, na.rm = TRUE, fill = "#E69F00", alpha = 0.3) +
    scale_x_discrete() +
    geom_jitter(aes_string(x = 0, y = col), alpha = 0.2, colour = "#999999", width = 0.3) +
    labs(x = col, y = "Values")
}

plot.singleBox2 <- function(data, col, label)
{
  p <- ggplot(data, aes_string(y = col, fill = label)) + 
    geom_boxplot(outlier.colour = "red", outlier.shape = 3, outlier.size = 1, na.rm = TRUE, alpha = 0.3) +
    scale_fill_manual(values = c("#999999", "#E69F00")) +
    #scale_x_discrete() +
    geom_jitter(aes_string(x = 0, y = col), alpha = 0.2, colour = "#999999", width = 0.3) +
    labs(x = col, y = "Values")
}



plot.singleBox3 <- function(data, col, label)
{
  p <- ggplot(data, aes_string(x = label, y = col, fill = label)) + 
    geom_violin(alpha = 0.3) +
    scale_fill_manual(values = c("#999999", "#E69F00")) +
    geom_jitter(alpha = 0.1, colour = "#999999", width = 0.3)
}



# -- Plot: value distribution over different labels
plot.singleDist <- function(data, col, group)
{
  p <- ggplot(data, aes_string(x = col, group = group, fill = group)) + 
    geom_density(alpha = 0.4) +
    scale_fill_manual(values = c("#999999", "#E69F00"))
}


# -- Plot: boxPlot over time
plot.timeBox <- function(data, col, time)
{
  p <- ggplot(data, aes_string(x = time, y = col, group = time)) + 
    geom_boxplot(outlier.colour = "red", outlier.shape = 3, outlier.size = 1, na.rm = TRUE, fill = "#E69F00", alpha = 0.3) +
    geom_jitter(aes_string(x = time, y = col), alpha = 0.2, colour = "#999999", width = 0.3) +
    labs(x = time, y = col) +
    scale_x_continuous(breaks = seq(1:12))
}

# -- Plot: boxPlot over time (group by label)
plot.timeBox2 <- function(data, col, time, label)
{
  ggplot(data, aes_string(x = sort(time), y = col, fill = label)) +
    geom_boxplot(alpha = 0.3) +
    #geom_jitter(aes_string(x = time, y = col), alpha = 0.1, colour = "#999999", width = 0.2) +
    scale_fill_manual(values = c("#999999", "#E69F00")) +
    scale_x_discrete(limits = month.abb)
  
}
