library(readr)
library(dplyr)

source("makestuff/makeRfuns.R") 

datlist <- csvReadList(skip=1, col_type="iccccccccccccccccccccccccccc")

datframe <- bind_rows(datlist, .id="file")

themeDate <- (datframe
	%>% transmute(
		published = as.Date(publishedAt)
		, main = `1st Theme`
	)
	%>% filter(!is.na(main))
)

print(themeDate
	%>% select(main)
	%>% distinct %>% pull %>% as.numeric %>% sort 
)

head(themeDate)

summary(themeDate)

csvSave(themeDate)

saveVars(themeDate)
