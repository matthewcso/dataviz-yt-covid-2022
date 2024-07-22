library(dplyr)
library(purrr)

export_folder <- "drive_files"
ignore <- 4 
col_types <- c(codingWeek='c', channelId='c', videoId='c', title='c', publishedAt='c', viewCount='d', likeCount='c', 
               dislikeCount='c', commentCount='c', duration='d', channelTitle='c', subscriberCount='d' , country='c', 
               videoURL='c', Language='d', `Source Type`='d', `1st Theme`= 'd', `2nd Theme`= 'd', Perspective= 'd', 
               Who='d', `Who Background`='d', Whom='d', Verification='c', Verification_1='c', Comments='c', Comment='c',
               Coder='d', X26='c', X27='c', X28='d')


data.frame(file_names = list.files(export_folder)) %>%
# order by week date range
dplyr::arrange(file_names) %>%
# remove additional_coding1.csv, we don't want it
dplyr::filter(!file_names %in% "additional_coding1.csv") %>%
# get rid of the pre-December file names, we don't want those
dplyr::slice(c(ignore+1:nrow(.))) %>%
# temporarily convert to vector so map works
(function(df) {df$file_names}) %>%
# read csv from every file name
map(function(f){
    readr::read_csv(paste(export_folder, "/", f, sep = ""), 
                    skip = 1, col_types=col_types)}) %>%
# convert into single csv
reduce(bind_rows) %>%
# There are 2 "Verification" columns, one is sometimes unnamed (converted to X26) and sometimes named
# (converted to Verification_1). We collapse these two columns together.
mutate(Verification_1 = dplyr::coalesce(.$Verification_1, .$X26)) %>%
# similar for comments and comment and X27, coder and X28
mutate(Comments = dplyr::coalesce(.$Comments, .$Comment, .$X27)) %>%
mutate(Coder = dplyr::coalesce(.$Coder, .$X28)) %>%
select(c(-X26, -X1,-X27, -X28, -Comment)) %>%
# write to CSV, we could also easily clean this first
readr::write_csv(file='aggregated_uncoded.csv')


