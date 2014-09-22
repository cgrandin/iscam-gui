#**********************************************************************************
# iscam-gui-figures-catch.r
# This file contains the code for catch values iscam inputs using the
# infrastructure provided with iscam-gui.
#
# Author            : Chris Grandin
# Development Date  : October 2013 - Present
#**********************************************************************************

plotCatch <- function(scenario   = 1,         # Scenario number
                      plotNum    = 1,         # Plot code number
                      savefig    = .SAVEFIG,  # TRUE/FALSE for plot output
                      fileText   = "Default", # Name of the file if png==TRUE
                      plotMCMC   = FALSE,     # TRUE/FALSE to plot MCMC output
                      ci         = NULL,      # confidence interval in % (0-100)
                      multiple   = FALSE,     # TRUE/FALSE to plot sensitivity cases
                      sensGroup  = 1,         # Sensitivity group to plot if multiple==TRUE
                      index      = 1,         # Survey index to plot if plotNum==7
                      # PlotSpecs: Width, height, and resolution of screen and file
                      ps         = list(pngres = .RESOLUTION,
                                        pngw   = .WIDTH,
                                        pngh   = .HEIGHT,
                                        res    = .RESOLUTION,
                                        w      = .WIDTH,
                                        h      = .HEIGHT),
                      leg        = "topright",# Legend location. If NULL, none will be drawn
                      figtype    = .FIGURE_TYPE, # The filetype of the figure with period, e.g. ".png"
                      units      = .UNITS,
                      silent     = .SILENT){

  # Assumes that 'op' list exists and has been populated correctly.
  # plotNum must be one of:
  # 1  Landings
  # 2
  # 3  Observed vs Expected landings
  currFuncName <- getCurrFunc()
  scenarioName <- op[[scenario]]$names$scenario
  inp          <- op[[scenario]]$inputs$data
  inputs       <- op[[scenario]]$inputs
  figDir       <- op[[scenario]]$names$figDir
  color        <- op[[scenario]]$inputs$color
  res          <- ps$pngres
  width        <- ps$pngw
  height       <- ps$pngh
  resScreen    <- ps$res
  widthScreen  <- ps$w
  heightScreen <- ps$h

  if(plotNum < 1 || plotNum > 4){
    return(FALSE)
  }
  isMCMC   <- op[[scenario]]$inputs$log$isMCMC
  figDir   <- op[[scenario]]$names$figDir
  out      <- op[[scenario]]$outputs$mpd

  filenameRaw  <- paste0(op[[scenario]]$names$scenario,"_",fileText,figtype)
  filename     <- file.path(figDir,filenameRaw)

 if(savefig){
    graphics.off()
    if(figtype == .PNG_TYPE){
      png(filename,res=res,width=width,height=height,units=units)
    }
    if(figtype == .EPS_TYPE){
      setEPS(horizontal=FALSE, onefile=FALSE, paper="special",width=width,height=height)
      postscript(filename)
    }
  }else{
    windows(width=widthScreen,height=heightScreen)
  }

  if(plotNum == 1){
    plotCatches(inp = inputs, scenarioName, leg = leg, col = color)
  }
  if(plotNum == 2){
    plotSPR(inp = inputs, scenarioName, leg = leg, col = color)
  }
  if(plotNum == 3){
    plotExpVsObsCatch(inp = inputs, out=out, scenarioName, leg = leg, col = color)
  }
  if(plotNum == 4){
      plotExpVsObsAnnualMeanWt(inp = inputs, out=out, scenarioName, leg = leg, col = color)
 }

  if(savefig){
    cat(.PROJECT_NAME,"->",currFuncName,"Wrote figure to disk: ",filename,"\n\n",sep="")
    dev.off()
  }
  return(TRUE)
}

plotCatches <- function(inp,
                        scenarioName,
                        verbose = FALSE,
                        leg = "topright",
                        col = 1){
  # Catch plot for iscam model, plots by gear
  oldPar <- par(no.readonly=TRUE)
  on.exit(par(oldPar))

  catch <- as.data.frame(inp$data$catch)
  p <- ggplot(catch,aes(x=factor(year),value,fill=factor(gear)))
	p <- p + geom_bar(width=0.75,position="dodge",stat="identity")
  p <- p + labs(x="Year",y="Catch",fill="Gear")
  p <- p + .PLOT_THEME
  p <- p + theme(axis.text.x = element_text(angle = -90, hjust = 0))
	print(p)
}

plotSPR <-  function(inp,
                     scenarioName,
                     verbose = FALSE,
                     leg = "topright",
                     col = 1){

}


plotExpVsObsCatch<-function(inp,
                            out,
                            scenarioName,
                            verbose = FALSE,
                            leg = "topright",
                            col = 1){

  oldPar <- par(no.readonly=TRUE)
  on.exit(par(oldPar))

  catchData <- as.data.frame(inp$data$catch)
  years <- catchData$year
  obsCt <- catchData$value
  gear <- catchData$gear
  gearList <- unique(gear)
  ngear <- length(gearList)
  predCt <- out$ct

  for (i in 1:ngear) {
      # Set-up plot area
      xLim <- range(years)
      yLim <- c(0,(max(obsCt[gear==gearList[i]],predCt[gear==gearList[i]])*1.1))
      plot(years[gear==gearList[i]], obsCt[gear==gearList[i]], pch=19, xlim=xLim, ylim=yLim, type="p", xlab="Year", ylab="Catch")
      lines(years[gear==gearList[i]], predCt[gear==gearList[i]], col="grey50")
  }
}

plotExpVsObsAnnualMeanWt<-function(inp,
                                out,
                                scenarioName,
                                verbose = FALSE,
                                leg = "topright",
                                col = 1){
  nmeanwtObs <- inp$data$nmeanwtobs
  if( nmeanwtObs > 0){
		  meanwtData <- inp$data$meanwtdata
		  years <- meanwtData[,"year"]
		  obsMeanWt <- meanwtData[,"meanwt"]
		  gear <-meanwtData[,"gear"]
		  gearList<-unique(gear)
		  ngear<-length(gearList)	 #only plot for gears with data
		  predMeanWt <-out$annual_mean_weight

		  if (ngear==1) par(mfrow=c(1,1),mar=c(5,4,2,2))
		  if (ngear == 2) par(mfrow=c(2,1),mar=c(4,4,2,2))
		  if (ngear == 3 | ngear == 4) par(mfrow=c(2,2),mar=c(3,3,2,2))
		  if (ngear == 5 | ngear == 6) par(mfrow=c(3,2),mar=c(2,2,2,2))

		  for (i in 1:ngear) {
		      # Set-up plot area
		      xLim <- range(years)
		      yLim <- c(0,(max(obsMeanWt[gear==gearList[i]],predMeanWt[gear==gearList[i]])*1.1))

		      plot(xLim, yLim, type="n", axes=TRUE, xlab="Year", ylab="Mean Weight in Catch")

		      points(years[gear==gearList[i]], obsMeanWt[gear==gearList[i]], pch=19)
		      lines(years[gear==gearList[i]], predMeanWt[gear==gearList[i]], col="red")
		      box()
		  }
		  par(mfrow=c(1,1),mar=c(5,4,2,2))
	}else cat("WARNING: No Annual Mean Weight Data")
}
