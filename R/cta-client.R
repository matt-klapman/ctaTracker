#' R6 class for accessing the CTA Transit Tracker API
#'
#' @description
#' A client to access the CTA Transit Tracker API. Can make requests to the API
#' as long as the user has their API Key set in their R environ as `TRAIN_KEY`.
#'
#' @export
#'
ctaclient <- R6::R6Class(
  classname = "ctaClient",
  public = list(
    
    #' @field api_url The base URL for the api. Generally shouldn't need to change,
    #' but leaving room for accessing future CTA APIs.
    api_url = NULL,
    
    #' @field last_request The last API request set up via `request()`
    last_request = NULL,
    
    #' @field last_response The most recent response from the API, if one has
    #' been made since initialization.
    last_response = NULL,
    
    #' @field last_response_body The body of the most recent response from the API,
    #' typically as list.
    last_response_body = NULL,
    
    #' @description
    #' Set up a new api client. Can change the base url here if needed.
    #'
    #' @param api_url The base url for the api. Will default to
    #' "http://lapi.transitchicago.com/api/1.0" if none provided. Left for
    #' future expansion.
    #'
    initialize = function(api_url = NULL) {
      self$api_url <- api_url %||% "http://lapi.transitchicago.com/api/1.0"
      return(invisible(self))
    },
    
    
    #' @description
    #' Build a `httr2` request object, but don't send it just yet.
    #'
    #' @param verb Method for request (e.g. 'GET', 'POST', ...)
    #' @param path Either character string or vector defining the api path appended
    #' to the end of the base url.
    #' @param body A list of any body contents necessary for the api request.
    #' @param query A list of any additional query parameters to append to the
    #' api request.
    #'
    request = function(verb, path, body = NULL, query = NULL) {
      
      if (!is.null(query)) {
        assertthat::assert_that(
          is.list(query),
          msg = "`query` must be a named list of query parameters to append to your URL."
        )
      }
      
      req <- httr2::request(self$api_url) %>%
        httr2::req_method(method = verb) %>%
        httr2::req_url_path_append(path) %>%
        httr2::req_url_query(key = private$token, !!!query)
      
      if (!is.null(body)) {
        assertthat::assert_that(
          is.list(body),
          msg = "`body` must be a list object."
        )
        req <- httr2::req_body_json(req, data = body)
      }
      
      self$last_request <- req
    },
    
    #' @description
    #' Actually perform the request set up by `request()`
    #'
    send = function() {
      assertthat::assert_that(
        !is.null(self$last_request),
        msg = "Please use `request()` to build an http request before sending it."
      )
      
      resp <- httr2::req_perform(self$last_request)
      
      self$last_response <- resp
      self$last_response_body <- httr2::resp_body_json(resp)
      return(self$last_response_body)
    },
    
    #' @description
    #' Print some basic information about the client.
    #'
    print = function() {
      cat(glue::glue(
        crayon::blue("CTA Train Tracker API client\n"),
        crayon::green("Base URL: "), self$api_url
      ))
    }
  ),
  
  private = list(
    token = Sys.getenv("TRAIN_KEY")
  )
)
