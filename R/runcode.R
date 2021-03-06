#' Construct to let you run arbitrary R code live in a Shiny app
#'
#' Sometimes when developing a Shiny app, it's useful to be able to run some R
#' code on-demand. This construct provides your app with a text input where you
#' can enter any R code and run it immediately.\cr\cr
#' This can be useful for testing
#' and while developing an app locally, but it \strong{should not be included in
#' an app that is accessible to other people}, as letting others run arbitrary R
#' code can open you up to security attacks.\cr\cr
#' To use this construct, you must add a call to \code{runcodeUI()} in the UI
#' of your app, and a call to \code{runcodeServer()} in the server function. You
#' also need to initialize shinyjs with a call to \code{useShinyjs()} in the UI.
#'
#' @note You can only have one \code{runcode} construct in your shiny app.
#' Calling this function multiple times within the same app will result in
#' unpredictable behaviour.
#'
#' @param code The initial R code to show in the text input when the app loads
#' @param type One of \code{"text"} (default), \code{"textarea"}, or \code{"ace"}. 
#' When using a text input, the R code will be limited to be typed within a single line,
#' and is the recommended option. Textarea should be used if you want to write
#' long multi-line R code. Note that you can run multiple expressions even in
#' a single line by appending each R expression with a semicolon.
#' Use of the \code{"ace"} option requires the \code{shinyAce} package.
#' @param width The width of the text or textarea input
#' @param height The height of the textarea input (only applicable when
#' \code{type="textarea"})
#' @param includeShinyjs Set this to \code{TRUE} only if your app does not have
#' a call to \code{useShinyjs()}. If you are already calling \code{useShinyjs()}
#' in your app, do not use this parameter.
#' @seealso \code{\link[shinyjs]{useShinyjs}}
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   shinyApp(
#'     ui = fluidPage(
#'       useShinyjs(),  # Set up shinyjs
#'       runcodeUI(code = "shinyjs::alert('Hello!')")
#'     ),
#'     server = function(input, output) {
#'       runcodeServer()
#'     }
#'   )
#' }
#' @name runcode

#' @rdname runcode
#' @export
runcodeUI <- function(code = "",
                      type = c("text", "textarea", "ace"),
                      width = NULL,
                      height = NULL,
                      includeShinyjs = FALSE) {
  type <- match.arg(type)
  placeholder <- "Enter R code"
	if(type == "ace")
		require(shinyAce)

  shiny::singleton(shiny::tagList(
    if (includeShinyjs)
      useShinyjs(),
    if(type == "text")
      shiny::textInput(
        "runcode_expr", label = NULL, value = code,
        width = width, placeholder = placeholder
      ),
    if(type == "textarea")
      shiny::textAreaInput(
        "runcode_expr", label = NULL, value = code,
        width = width, height = height, placeholder = placeholder
      ),
    if(type == "ace") 
			shinyAce::aceEditor("runcode_expr", mode='r', value=code,
				width = width, height = height, 
				theme = "github", vimKeyBinding=TRUE, fontSize=16, hotkeys=list(runKey="F8|F9|F2|Ctrl-R")),
    shiny::actionButton("runcode_run", "Run", class = "btn-success"),
    shinyjs::hidden(
      shiny::div(
        id = "runcode_error",
        style = "color: red; font-weight: bold;",
        shiny::div("Oops, that resulted in an error! Try again."),
        shiny::div("Error: ", shiny::br(),
                   shiny::tags$i(shiny::span(
                     id = "runcode_errorMsg", style = "margin-left: 10px;")))
      )
    )
  ))
}

#' @rdname runcode
#' @export
runcodeServer <- function() {
  # evaluate expressions in the caller's environment
  parentFrame <- parent.frame(1)

  # get the Shiny session
  session <- getSession()

  shiny::observeEvent(session$input[['runcode_run']], {
    shinyjs::hide("runcode_error")

    tryCatch(
      shiny::isolate(
        eval(parse(text = session$input[['runcode_expr']]), envir = parentFrame)
      ),
      error = function(err) {
        shinyjs::html("runcode_errorMsg", as.character(err$message))
        shinyjs::show(id = "runcode_error", anim = TRUE, animType = "fade")
      }
    )
  })

  invisible(NULL)
}
