
ctaclient <- R6::R6Class(
  classname = "ctaClient",
  public = list(
    api_url = "http://lapi.transitchicago.com/api/1.0",
    last_request = NULL,
    last_response = NULL,
    last_response_body = NULL,
    
    initialize = function(api_url = NULL) {
      return(invisible(self))
    },
    
    request = function(verb, path, body = NULL, query = NULL) {
      
      if (!is.null(query)) {
        assertthat::assert_that(
          is.list(query),
          msg = "`query` must be a named list of query parameters to append to your URL."
        )
        req <- httr2::req_body_json(req, data = body)
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
    
    send = function() {
      assertthat::assert_that(
        !is.null(self$last_request),
        msg = "Please use `request()` to build an http request before sending it."
      )
      
      resp <- httr2::req_perform(self$last_request)
      
      self$last_response <- resp
      self$last_response_body <- httr2::resp_body_json(resp)
    }
  ),
  
  private = list(
    token = Sys.getenv("TRAIN_KEY")
  )
)
