#' Print any JavaScript console.log messages in the R console
#'
#' When developing and debugging a Shiny that uses custom JavaScript code,
#' it can be helpful to use \code{console.log()} messages in JavaScript. This
#' function allows you to see these messages printed in the R console directly
#' rather than having to open the JavaScript console in the browser to view the
#' messages.\cr\cr
#' This function must be called in a Shiny app's server function, and you also
#' need to pass the \code{showLog=TRUE} parameter to \code{useShinyjs()}.
#' @note Due to an issue in shiny (see
#' https://github.com/rstudio/shiny/issues/928), duplicated consecutive log
#' messages will not get printed in R.
#' @note Log messages that cannot be serialized in JavaScript (such as many
#' JavaScript Event objects that are cyclic) will not be printed in R.
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       useShinyjs(showLog = TRUE),  # Set up shinyjs with showLog
#'       textInput("text", "Type something")
#'     ),
#'     server = function(input, output) {
#'       showLog()
#'       observe({
#'         logjs(paste("Length of text:", nchar(input$text)))
#'       })
#'     }
#'   )
#' }
#' @seealso \code{\link[shinyjs]{logjs}}
#' @export
showLog <- function() {
  session <- getSession()
  shiny::observeEvent(session$input[['shinyjs-showLog']], {
    message("JAVASCRIPT LOG: ",
            jsonlite::toJSON(session$input[['shinyjs-showLog']],
                             auto_unbox = TRUE)
    )
  })
}
