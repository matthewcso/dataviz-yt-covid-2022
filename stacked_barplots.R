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
ggsave('figures/theme_by_source_stack.png', height=HEIGHT, width = WIDTH)

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
ggsave('figures/theme_by_source_wfill.png', height=HEIGHT, width = WIDTH)

plot = ggplot(data=aggregated_df, aes(x=reorder(source_col, count, mean), y=count, fill=reorder(theme_col, count, mean))) + scale_color_colorblind()
plot = plot + geom_bar(position='fill', stat='identity', alpha=1) + labs(x='Source', y='Proportion', title='Theme by source') 
plot = plot + scale_fill_discrete(name = "")
plot = plot + scale_x_discrete(labels = function(x) str_wrap(str_replace_all(x, "\n" , " "),
                                                             width = 10))

print(plot)
ggsave('figures/theme_by_source_fill.png', height=HEIGHT, width = WIDTH)

#rm(list=ls())
