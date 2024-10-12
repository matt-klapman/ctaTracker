#' R6 Class Representing a CTA Train Route
#'
#' @description
#' This class can be used to grab the positions of all trains along a
#' #' specific CTA Train Line (Brown, Red, Blue, etc.).
#'
route <- R6::R6Class(
  classname = "route",
  active = list(
    
    #' @field rt_name (`character`) Name of the route set at initialization.
    rt_name = function(value) {
      if (!missing(value)) {
        stop(
          "rt_name is read-only. Please set at initialization."
        )
      } else {
        return(private$.rt_name)
      }
    },
    
    #' @field rt_code (`character`) Special code based on `rt_name`. Note that
    #' sometimes this value will be exactly equal to `rt_name`.
    rt_code = function(value) {
      if (!missing(value)) {
        stop(
          "rt_code is read-only and based on the value of rt_name."
        )
      } else {
        return(private$.rt_code)
      }
    }
  ),
  public = list(
    
    #' @field client Instance of the ctaclient class.
    client = NULL,
    
    #' @field trains A list of trains on the route with additional information.
    trains = NULL,
    
    #' @field time_stamp Time stamp (in US/Central time) of the most recent API
    #' call to retrieve `trains` information.
    time_stamp = NULL,
    
    #' @description
    #' Generates a new `route` object.
    #'
    #' @param rt_name Name of the desired route (e.g. "Brown", "Red", ...). See
    #' `ctaTracker::train_routes` for full list of options.
    #'
    #' @param client Instance of ctaclient API client to interact with the
    #' CTA Train Tracker API. Will default to basic client if none provided.
    #' Other values generally only needed for testing purposes.
    #'
    initialize = function(rt_name, client = NULL) {
      assertthat::assert_that(
        rt_name %in% names(train_routes),
        msg = glue::glue("Must provide a `rt_name` value from the ",
                         "following: {toString(names(train_routes))}")
      )
      
      logger::log_debug("Setting api client")
      self$client <- client %||% .clients$get_client("cta")
      
      logger::log_debug("Setting overall variables")
      private$.rt_name <- rt_name
      private$.rt_code <- train_routes[[rt_name]]
      
      return(invisible(self))
    },
    
    #' @description
    #' Print some basic information about the route.
    #'
    print = function() {
      base_output <- glue::glue(
        crayon::blue("CTA Train Route\n"),
        crayon::green("Name: "), "{self$rt_name}\n",
        crayon::green("Code: "), "{self$rt_code}\n\n",
      )
      
      cat(base_output)
      
      if (!is.null(self$trains)) {
        train_output <- glue::glue(
          crayon::green("Trains on route: "), length(self$trains), "\n",
          crayon::green("Last updated: "),
          as.character(self$time_stamp), " US/Central\n"
        )
        cat(train_output)
      }
      cat("\n")
    },
    
    #' @description
    #' Grab all current trains on the route and any information about them.
    #' Send results to `self$trains`
    #'
    get_positions = function() {
      
      self$client$request(
        verb = "GET",
        path = "ttpositions.aspx",
        query = list(
          rt = self$rt_code,
          outputType = "JSON"
        )
      )
      
      resp <- self$client$send()
      
      if (resp$ctatt$errCd == "0") {
        self$time_stamp <- lubridate::as_datetime(resp$ctatt$tmst, tz = "US/Central")
        
        self$trains <- purrr::imap(resp$ctatt$route[[1]]$train, ~{
          logger::log_debug("Formatting train {.y}")
          return(private$format_train(.x))
        })
      } else {
        logger::log_error(
          "Error in getting train positions. Original error ",
          "{resp$ctatt$errCd}: {resp$ctatt$errNm}"
        )
        self$trains <- NULL
      }
      
      return(invisible(self))
    }
  ),
  private = list(
    .rt_code = NULL,
    .rt_name = NULL,
    
    format_train = function(train) {
      assertthat::assert_that(
        is.list(train),
        msg = "train must be a list object"
      )
      
      out <- list(
        run = as.numeric(train$rn),
        dest = train$destSt,
        dest_name = train$destNm,
        dir = train$trDr,
        dir_cardinal = switch(train$trDr, "1" = "N", "5" = "S"),
        next_station = train$nextStaId,
        next_station_nm = train$nextStaNm,
        next_stop = train$nextStpId,
        pred_updated = lubridate::as_datetime(train$prdt, tz = "US/Central"),
        pred_arrival = lubridate::as_datetime(train$arrT, tz = "US/Central"),
        due = ifelse(train$isApp == "1", TRUE, FALSE),
        delayed = ifelse(train$isDly == "1", TRUE, FALSE),
        coord = c(train$lat, train$lon),
        degrees = as.numeric(train$heading)
      )
      
      out$time_to_arrival <- ifelse(
        out$due,
        "DUE",
        round(as.numeric(difftime(out$pred_arrival, self$time_stamp, units = "mins")))
      )
      
      return(out)
    }
  )
)
