
.clients <- new.env()
.clients$get_client <- function(name) {
  valid_clients <- c("cta")
  assertthat::assert_that(
    name %in% valid_clients,
    msg = glue::glue("Current valid clients are {toString(valid_clients)}")
  )
  
  if (is.null(.clients[[name]])) {
    logger::log_info("Initializing new {crayon::blue(name)} client.")
    out <- switch(
      name, 
      cta = ctaclient$new()
    )
    .clients[[name]] <- out
  } else {
    logger::log_debug("Reusing {crayon::blue(name)} client")
    out <- .clients[[name]]
  }
  
  return(out)
}
