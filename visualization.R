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

dir.create('figures', showWarnings=FALSE)




#######################################################################################################
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
ggsave('figures/total_n_videos_top50.png', height=6.53, width = 16.3)


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
ggsave('figures/mean_views_top50_descaled.png', height=6.53, width = 16.3)


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
ggsave('figures/mean_views_top50.png', height=6.53, width = 16.3)


########################################################################################################3


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
ggsave('figures/mean_viewcounts_by_theme.png', height=6.53, width = 16.3)



plot = ggplot(data=aggregate_df, aes(x=reorder(unique_themes, total_n_videos, mean), y=total_n_videos, fill=unique_themes)) 
plot = plot + geom_bar(position='stack', stat='identity', alpha=0.5)
plot = plot + labs(title='Number of coded videos by theme', x='Theme', y='Total number of videos')
plot = plot + theme(legend.position = "none")
plot = plot + geom_text(aes(label=total_n_videos), position=position_dodge(width=0.9), vjust=-0.5, size=10)
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
plot = plot + ylim(0, 135)
print(plot)
ggsave('figures/total_videos_by_theme.png', height=6.53, width = 16.3)
##plot = plot + geom_point(aes(x=reorder(unique_themes,  total_n_videos, mean), y=total_n_videos,fill=reorder(unique_themes,  total_n_videos, mean), size=10), show.legend=FALSE) 
#plot = plot + geom_errorbar(aes(ymin=lows, ymax=highs))

################################################################################################################


unique_sources = sort(unique(coded_data$Source.Type.String))
total_n_videos = c()
mean_viewcounts = c()
lows = c()
highs = c()
for(theme in unique_sources){
   relevant_data = coded_data[coded_data$Source.Type.String == theme,]
   total_n_videos = append(total_n_videos, length(relevant_data$viewCount))
   
   this_mean = mean(relevant_data$viewCount)
   mean_viewcounts = append(mean_viewcounts, this_mean)
   this_SE = SE(relevant_data$viewCount)
   lows = append(lows, this_mean - this_SE)
   highs = append(highs, this_mean + this_SE)
}

aggregate_df = data.frame(sources = unique_sources, total_n_videos = total_n_videos, mean_viewcounts=mean_viewcounts, lows = lows, highs = highs)
aggregate_df= aggregate_df[!c(aggregate_df$sources=='Not coded'),]
unique_sources = unique_sources[!c(unique_sources=='Not coded')]

plot = ggplot(data=aggregate_df, aes(x=reorder(unique_sources, mean_viewcounts, mean), y=mean_viewcounts, fill=unique_sources)) 
#plot = plot + geom_bar(position='stack', stat='identity', alpha=0.5)

plot = plot + geom_errorbar(aes(ymin=lows, ymax=highs))
plot = plot + geom_point(aes(x=reorder(unique_sources, mean_viewcounts, mean), y=mean_viewcounts,fill=reorder(unique_sources, mean_viewcounts, mean), size=10), alpha=1, show.legend=FALSE) 

plot = plot + labs(title='Mean view counts by source', x='Source', y='Mean viewcounts')
plot = plot + theme(legend.position = "none")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))

print(plot)
ggsave('figures/mean_viewcounts_by_source.png', height=6.53, width = 16.3)



plot = ggplot(data=aggregate_df, aes(x=reorder(unique_sources, total_n_videos, mean), y=total_n_videos, fill=unique_sources)) 
plot = plot + geom_bar(position='stack', stat='identity', alpha=0.5)
plot = plot + labs(title='Number of coded videos by source', x='Theme', y='Total number of videos')
plot = plot + theme(legend.position = "none")
plot = plot + geom_text(aes(label=total_n_videos), position=position_dodge(width=0.9), vjust=-0.5, size=10)
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
plot = plot + ylim(0, 380)
print(plot)
ggsave('figures/total_videos_by_source.png', height=6.53, width = 16.3)

#######################################################################################################

coded_data = read.csv('aggregated_coded_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)


unique_days = sort(unique(coded_data$day))

unique_themes = sort(unique(coded_data$X1st.Theme.String))
total_n_videos = c()
mean_viewcounts = c()
corresponding_themes = c()
new_days = c()



for(day in unique_days){
   for(theme in unique_themes){
      relevant_data = coded_data[(coded_data$day == day),]
      relevant_data = relevant_data[(relevant_data$X1st.Theme.String)==theme,]
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
         + coord_cartesian(ylim = c(-0.05, 1.2))

         + xlim(as.Date(c('1/1/2020', '1/10/2020'), format = "%d/%m/%Y"))
         + labs(y='Number of videos per day', x='Date')
         + ggtitle('Number of coded videos by day and theme')
         + scale_fill_discrete_qualitative()
         + scale_colour_discrete_qualitative()
)

plot = direct.label(plot,method=list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/coded_videos_day_theme.png', height=6.53, width = 16.3)


plot <- (ggplot(coded_data) #aggregate_df) 
         + aes(x=day, y=viewCount, variable=X1st.Theme.String, color=X1st.Theme.String) 
         + geom_smooth(alpha=0.05, method="loess", formula=y~x, span=1, aes(fill=X1st.Theme.String))
         #         + geom_point(alpha=0.5, color='red')
         + coord_cartesian(ylim = c(0, 5.5e+6))
         + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + xlim(as.Date(c('1/1/2020', '1/10/2020'), format = "%d/%m/%Y"))
         + labs(y='Mean view counts per video', x='Date')
         + ggtitle('Mean view counts by day and theme')
)

plot = direct.label(plot,list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/viewcount_day_theme.png', height=6.53, width = 16.3)

#######################################################################################################################
coded_data = read.csv('aggregated_coded_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)


coded_data = coded_data[!c(coded_data$Source.Type.String=='Not coded'),]

unique_sources = sort(unique(coded_data$Source.Type.String))

total_n_videos = c()
mean_viewcounts = c()
corresponding_themes = c()
new_days = c()

for(day in unique_days){
   for(theme in unique_sources){
      relevant_data = coded_data[(coded_data$day == day),]
      relevant_data = relevant_data[(relevant_data$Source.Type.String)==theme,]
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
         + coord_cartesian(ylim = c(-0.05, 2))
         + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + xlim(as.Date(c('1/1/2020', '10/11/2020'), format = "%d/%m/%Y"))
         + labs(y='Number of videos per day', x='Date')
         + ggtitle('Number of coded videos by day and source')
)

plot = direct.label(plot,list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/coded_videos_day_source.png', height=6.53, width = 16.3)



plot <- (ggplot(coded_data) 
         + aes(x=day, y=viewCount, variable=Source.Type.String, color=Source.Type.String) 
         + geom_smooth(alpha=0.05, method="loess", formula=y~x, span=1, aes(fill=Source.Type.String))
         + coord_cartesian(ylim = c(0, 7.5e+6))
         + scale_fill_discrete_qualitative() + scale_colour_discrete_qualitative()
         + xlim(as.Date(c('1/1/2020', '10/11/2020'), format = "%d/%m/%Y"))
         + labs(y='Mean view counts per video', x='Date')
         + ggtitle('Mean view counts by day and source')
)

plot = direct.label(plot,list(cex=1.5, "last.bumpup"))
print(plot)
ggsave('figures/viewcount_day_source.png', height=6.53, width = 16.3)

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
ggsave('figures/coded_prevention_videos_day_theme.png', height=6.53, width = 16.3)


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
ggsave('figures/prevention_viewcount_day_theme.png', height=6.53, width = 16.3)

########################################################################################

coded_data = read.csv('aggregated_coded_data.csv')
coded_data$day = as.Date(coded_data$publishedAt)

coded_data = coded_data[!c(coded_data$Source.Type.String=='Not coded'),]
unique_sources = sort(unique(coded_data$Source.Type.String))
unique_themes = sort(unique(coded_data$X1st.Theme.String))

source_col = c()
theme_col = c()
count_col = c()
widths = c()

for(source in unique_sources){
   for(theme in unique_themes){
      relevant_data = coded_data[coded_data$Source.Type.String == source,]
      relevant_data = relevant_data[relevant_data$X1st.Theme.String == theme,]
      N = length(relevant_data$day)
      source_col = append(source_col, source)
      theme_col = append(theme_col, theme)
      count_col = append(count_col, N)
   }
   relevant_data = coded_data[coded_data$Source.Type.String == source,]
   widths = append(widths, length(relevant_data$day))
}
aggregated_df = data.frame(source=source_col, theme=theme_col, count=count_col)


plot = ggplot(data=aggregated_df, aes(x=reorder(source_col, count, mean), y=count, fill=reorder(theme_col, count, mean))) + scale_color_colorblind()
plot = plot +geom_bar(position='stack', stat='identity') + labs(x='Source', y='Count', title='Theme by source') 
plot = plot + scale_fill_discrete(name = "")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
print(plot)
ggsave('figures/theme_by_source_stack.png', height=6.53, width = 16.3)

widths = widths/sum(widths)*1.5
bar_widths = c()
for(width in widths){
   bar_widths = append(bar_widths, replicate(length(unique_themes), width))
}
bar_widths
plot = ggplot(data=aggregated_df, aes(x=reorder(source_col, count, mean), y=count, fill=reorder(theme_col, count, mean))) + scale_color_colorblind()
plot = plot + geom_bar(position='fill', stat='identity', alpha=1, width= bar_widths) + labs(x='Source', y='Proportion', title='Theme by source') 
plot = plot + scale_fill_discrete(name = "")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))
print(plot)
ggsave('figures/theme_by_source_wfill.png', height=6.53, width = 16.3)

plot = ggplot(data=aggregated_df, aes(x=reorder(source_col, count, mean), y=count, fill=reorder(theme_col, count, mean))) + scale_color_colorblind()
plot = plot + geom_bar(position='fill', stat='identity', alpha=1) + labs(x='Source', y='Proportion', title='Theme by source') 
plot = plot + scale_fill_discrete(name = "")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))

print(plot)
ggsave('figures/theme_by_source_fill.png', height=6.53, width = 16.3)

#rm(list=ls())