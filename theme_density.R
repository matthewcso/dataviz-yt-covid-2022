library(ggplot2); theme_set(theme_bw())

source("makestuff/makeRfuns.R") 

makeGraphics()

commandEnvironments()

summary(themeCountDaily)

print(ggplot(themeCountDaily)
	+ aes(x=published, y=n, color=main)
	+ geom_point()
	+ geom_smooth()
	+ coord_cartesian(ylim=c(0, 1.5))
)
