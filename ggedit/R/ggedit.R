#' @title Interactive shiny gadget for editing ggplot layers and themes.
#' @export
#' @description 
#' Shiny gadget that takes an input ggplots and populates a user interface 
#' with objects that let the user update aesthetics of layers and theme elements. 
#' 
#' @param p.in ggplot plot object or list of objects
#' @param viewer shiny viewer options. It can be either paneViewer, dialogViewer, browserViewer
#' @param verbose logical to control if the output includes script for layers and themes calls for parsing to create objects (default, verbose=F)
#' @param \dots parameters that are passed to shiny viewer functions
#' @details 
#' An interactive shiny gadget that inputs ggplot objects.
#' 
#' The user can start the gadget using the console \code{ggedit(plotobj)} or 
#' through the Addins menu in Rstudio. If you are using the the Addin option 
#' highlight on the editor window the ggplot object and then click the addin.
#' 
#' Once the gadget is running the list of plots are shown in a grid and a number of objects will appear above them.
#' 
#' \strong{Action buttons}
#' 
#' Cancel: 
#' 
#' Returns a NULL object
#' 
#' Done: 
#' 
#' Returns the list decribed below. 
#' 
#' \strong{Dropdown list} 
#' 
#' Navigates through the plots in the input list. If the input list is a named list the names will be in the dropdown. The plot chosen is termed as the "active plot"
#' 
#' \strong{Radio buttons} 
#' 
#' The options to choose in the radio buttons are the layer names in the active plot.
#' 
#' \strong{Links}
#' 
#' Update Plot Layer: 
#' 
#' A pop up window will appear and be populated with aesthetic elements found in the layer chosen from the radio buttons.
#' The layer is cloned using \code{\link{cloneLayer}} creating a layer independent of the original plot.

#' If the aesthetic is a factor the values will be shown in dropdown lists. 
#' If it is numeric it will be shown in a slider. 
#' If it is a factor colour/fill aesthetic the \code{\link{colourpicker}} package will allow to choose from the full pallete of colours.
#' If the continuous colour/fill aesthetic a dropdown list will be shown with different palletes
#' 
#' Update Plot Theme:
#' 
#' A popup modal will appear populated with the theme elements found in the active plot.
#' Each element will appear as having a value or empty depending if it was defined or not.
#' The user can change or fill in any element \href{http://docs.ggplot2.org/current/theme.html}{with valid values} 
#' and any textboxes left empty will use ggplot defaults.
#' 
#' Update Grid Theme:
#' 
#' Copies the theme of the active plot to the other plots in the list 
#' 
#' Update Global Theme:
#' 
#' Copies the theme of the active plot to the session theme and all plots created outside of the gadget will have this theme. 
#' 
#' View Layer Code:
#' 
#' Opens an ace editor to compare the active layer initial script call and the updated script call.
#' 
#' The ggplot objects returned (layers and themes) can be used on any ggplot object.
#' @return 
#' List of elements
#' \describe{
#' \item{updatedPlots}{list containing updated ggplot objects}
#' \item{updatedLayers}{For each plot a list of updated layers (ggproto) objects}
#' \item{UpdatedLayersElements}{For each plot a list elements and their values in each layer}
#' \item{UpdatedLayerCalls}{For each plot a list of scripts that can be run directly from the console to create a layer}
#' \item{updatedScales}{For each plot a list of updated scale objects}
#' \item{UpdatedScalesCalls}{For each plot a list of scripts that can be run directly from the console to create a scale object}
#' \item{updatedThemes}{For each plot a list of updated theme objects}
#' \item{UpdatedThemeCalls}{For each plot a list of scripts that can be run directly from the console to create a theme}
#' } 
#'
#' 
#' @seealso 
#' \code{\link{cloneLayer}},\code{\link{rgg}},\code{\link[ggplot2]{ggplot}},\code{\link[colourpicker]{colourPicker}}
#' @examples
#' p=ggplot(iris,aes(x =Sepal.Length,y=Sepal.Width))
#' p=p+geom_point(aes(colour=Species))+geom_line()
#' \donttest{
#' pnew=ggedit(p)
#' pnew
#' }

ggedit <- function(p.in,viewer=paneViewer(minHeight = 1000),verbose=F,...) {

  if(!Sys.getenv("RSTUDIO") == "1") viewer=browserViewer()
  
  if(is.ggplot(p.in)) p.in=list(p.in)
  
  if(is.null(names(p.in))) names(p.in)=as.character(1:length(p.in))
  
  p.names=split(1:length(p.in),names(p.in))
  
  if(!all(unlist(lapply(p.in,is.ggplot)))) stop("'object' is not a valid ggplot object")
  
  if(!exists('minHeight')) minHeight=1000
  
  if(deparse(substitute(viewer))=='paneViewer()') viewer=paneViewer(minHeight)
  
  assign('.minHeight',envir = ggedit:::.ggeditEnv,minHeight)
  assign('.p',envir = ggedit:::.ggeditEnv,p.in)
  assign('.verbose',envir = ggedit:::.ggeditEnv,verbose)
  ggeditGadget()
  }