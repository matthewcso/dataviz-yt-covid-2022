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
coded_data = read.csv('aggregated_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)


unique_days = sort(unique(coded_data$day))

total_n_videos = c()
mean_viewcounts = c()


for(day in unique_days){
  relevant_data = coded_data[coded_data$day == day,]
  total_n_videos = append(total_n_videos, length(relevant_data$day))
  mean_viewcounts = append(mean_viewcounts, mean(relevant_data$viewCount))
}

aggregate_df = data.frame(day=unique_days, total_n_videos = total_n_videos, mean_viewcounts=mean_viewcounts)

plot <- (ggplot(aggregate_df) 
         + aes(x=day, y=total_n_videos) 
         + geom_smooth(alpha=0.1, method="loess", formula=y~x, span=0.5, color='black')
         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(0, 17))
         # +  + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + scale_fill_discrete_qualitative()
         + scale_colour_discrete_qualitative()
         # + xlim(as.Date(c('1/1/2020', '1/12/2020'), format = "%d/%m/%Y"))
         + labs(y='Number of videos', x='Date')
         + ggtitle('Number of videos - note this is not informative')
)

#plot = direct.label(plot,method="last.bumpup")
print(plot)
ggsave('figures/total_n_videos_top50.png', height=HEIGHT, width = WIDTH)


plot <- (ggplot(aggregate_df) 
         + aes(x=day, y=mean_viewcounts) 
         + geom_smooth(alpha=0.1, method="loess", formula=y~x, span=0.5, color='black')
         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(0, 3.2e+7))
         + scale_fill_discrete_qualitative()
         + scale_colour_discrete_qualitative()
         #   +  + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         #+ xlim(as.Date(c('1/1/2020', '1/12/2020'), format = "%d/%m/%Y"))
         + labs(y='Mean view counts', x='Date')
         + ggtitle('Mean view counts by date')
)

#plot = direct.label(plot,method="last.bumpup")
print(plot)
ggsave('figures/mean_views_top50_descaled.png', height=HEIGHT, width = WIDTH)


plot <- (ggplot(aggregate_df) 
         + aes(x=day, y=mean_viewcounts) 
         + geom_smooth(alpha=0.1, method="loess", formula=y~x, span=0.5, color='black')
         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(0, 4500000))
         + scale_fill_discrete_qualitative()
         + scale_colour_discrete_qualitative()
         #    +  + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         #    + xlim(as.Date(c('1/1/2020', '1/12/2020'), format = "%d/%m/%Y"))
         + labs(y='Mean view counts', x='Date')
         + ggtitle('Mean view counts by date')
)

#plot = direct.label(plot,method="last.bumpup")
print(plot)
ggsave('figures/mean_views_top50.png', height=HEIGHT, width = WIDTH)