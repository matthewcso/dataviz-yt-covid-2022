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





######################################################################################


coded_data = read.csv('aggregated_coded_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)


unique_days = sort(unique(coded_data$day))

coded_data = coded_data[!c(coded_data$Prevention.String=='Not prevention'),]
unique_themes = sort(unique(coded_data$Prevention.String))

total_n_videos = c()
mean_viewcounts = c()
corresponding_themes = c()
new_days = c()

for(day in unique_days){
  for(theme in unique_themes){
    relevant_data = coded_data[(coded_data$day == day),]
    relevant_data = relevant_data[(relevant_data$Prevention.String)==theme,]
    total_n_videos = append(total_n_videos, length(relevant_data$day))
    mean_viewcounts = append(mean_viewcounts, mean(relevant_data$viewCount))
    corresponding_themes = append(corresponding_themes, theme)
    new_days = append(new_days, day)
  }
}
new_days = as.Date(new_days,origin ="1970-01-01")

aggregate_df = data.frame(day=new_days, corresponding_themes = corresponding_themes, mean_viewcounts=mean_viewcounts, total_n_videos=total_n_videos)

plot <- (ggplot(aggregate_df) 
         + aes(x=day, y=total_n_videos, variable=corresponding_themes, color=corresponding_themes) 
         + geom_smooth(alpha=0.05, method="loess", formula=y~x, span=1, aes(fill=corresponding_themes))
         #         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(-0.05, 0.4))
         +  scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + xlim(as.Date(c('1/1/2020', '10/9/2020'), format = "%d/%m/%Y"))
         + labs(y='Number of videos per day', x='Date')
         + ggtitle('Number of coded prevention videos by day and subtheme')
         
)


plot = direct.label(plot,method=list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/coded_prevention_videos_day_theme.png', height=HEIGHT, width = WIDTH)


plot <- (ggplot(coded_data) #aggregate_df) 
         + aes(x=day, y=viewCount, variable=Prevention.String, color=Prevention.String) 
         + geom_smooth(alpha=0.05, method="loess", formula=y~x, span=1, aes(fill=Prevention.String))
         #         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(0, 4e+6))
         + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + xlim(as.Date(c('1/1/2020', '10/9/2020'), format = "%d/%m/%Y"))
         + labs(y='Mean view counts per video', x='Date')
         + ggtitle('Mean view counts by day and subtheme')
)

plot = direct.label(plot,method=list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/prevention_viewcount_day_theme.png', height=HEIGHT, width = WIDTH)