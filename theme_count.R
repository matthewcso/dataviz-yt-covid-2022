library(dplyr)
library(tidyr)

source("makestuff/makeRfuns.R") 

commandEnvironments()

## Check theme list
print(themeDate
	%>% group_by(main)
	%>% tally
)

themeCountDaily <- (themeDate
	%>% group_by(published, main)
	%>% tally
	%>% ungroup
	%>% complete(published, main
		, fill = list(n=0)
	)
)

saveVars(themeCountDaily)

