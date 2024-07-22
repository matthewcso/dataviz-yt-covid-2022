library(dplyr)
library(tidyr)

source("makestuff/makeRfuns.R") 

commandEnvironments()
names <- tsvRead()

summary(themeDate)

themeDate <- (themeDate
	%>% mutate(code=trunc(as.numeric(main)))
)

themeDate <- left_join(themeDate, names)
summary(themeDate)

csvSave(themeDate)

saveVars(themeDate)
