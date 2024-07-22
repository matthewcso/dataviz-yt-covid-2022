library(ggplot2)
library(directlabels)
library(RColorBrewer)
library(reshape2)
library(dplyr)
library('stringr')
library(ggthemes)
library(colorspace)
library(cowplot)

theme_set(theme_bw())
theme_update(text = element_text(size=24))

# 16.3 x 6.53 is good
HEIGHT =6.53
WIDTH = 16.3
dir.create('figures', showWarnings=FALSE)



coded_data = read.csv('aggregated_coded_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)

SE <- function(x) {sd(x)/sqrt(length(x))}

unique_themes = sort(unique(coded_data$X1st.Theme.String))
total_n_videos = c()
mean_viewcounts = c()
lows = c()
highs = c()
for(theme in unique_themes){
  relevant_data = coded_data[coded_data$X1st.Theme.String == theme,]
  total_n_videos = append(total_n_videos, length(relevant_data$viewCount))
  
  this_mean = mean(relevant_data$viewCount)
  mean_viewcounts = append(mean_viewcounts, this_mean)
  this_SE = SE(relevant_data$viewCount)
  lows = append(lows, this_mean - this_SE)
  highs = append(highs, this_mean + this_SE)
}

aggregate_df = data.frame(themes = unique_themes, total_n_videos = total_n_videos, mean_viewcounts=mean_viewcounts, lows = lows, highs = highs)

plot = ggplot(data=aggregate_df, aes(x=reorder(unique_themes, mean_viewcounts, mean), y=mean_viewcounts, fill=unique_themes)) 
#plot = plot + geom_bar(position='stack', stat='identity', alpha=0.5)

plot = plot + geom_errorbar(aes(ymin=lows, ymax=highs))
plot = plot + geom_point(aes(x=reorder(unique_themes, mean_viewcounts, mean), y=mean_viewcounts,fill=reorder(unique_themes, mean_viewcounts, mean), size=10), alpha=1, show.legend=FALSE) 

plot = plot + labs(title='Mean view counts by theme', x='Theme', y='Mean viewcounts')
plot = plot + theme(legend.position = "none")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
print(plot)
ggsave('figures/mean_viewcounts_by_theme.png', height=HEIGHT, width = WIDTH)

plot = ggplot(data=aggregate_df, aes(x=reorder(unique_themes, total_n_videos, mean), y=total_n_videos, fill=unique_themes)) 
plot = plot + geom_bar(position='stack', stat='identity', alpha=0.5)
plot = plot + labs(title='Number of coded videos by theme', x='Theme', y='Total number of videos')
plot = plot + theme(legend.position = "none")
plot = plot + geom_text(aes(label=total_n_videos), position=position_dodge(width=0.9), vjust=-0.5, size=10)
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
plot = plot + ylim(0, 135)
print(plot)
ggsave('figures/total_videos_by_theme.png', height=HEIGHT, width = WIDTH)
##plot = plot + geom_point(aes(x=reorder(unique_themes,  total_n_videos, mean), y=total_n_videos,fill=reorder(unique_themes,  total_n_videos, mean), size=10), show.legend=FALSE) 
#plot = plot + geom_errorbar(aes(ymin=lows, ymax=highs))
