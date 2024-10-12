

test_that("Base route generates with no trains", {
  local_edition(3)
  route1 <- route$new("Brown")
  expect_snapshot(route1)
  expect_equal(route1$rt_code, "Brn")
  expect_equal(route1$rt_name, "Brown")
  expect_null(route1$time_stamp)
  expect_null(route1$trains)
})

httptest2::with_mock_dir("route-tests", {
  test_that("Route get_positions works correctly", {
    
    route2 <- route$new("Pink")
    route2$get_positions()
    expect_length(route2$trains, 4)
    expect_snapshot(jsonlite::toJSON(
      route2$trains, auto_unbox = TRUE, pretty = TRUE
    ))
    
    expect_equal(
      route2$time_stamp,
      lubridate::as_datetime("2024-10-11 20:59:17", tz = "US/Central")
    )
  })
})

test_that("Base route object errors as expected", {
  expect_error(
    route$new("Magenta"),
    regexp = "Must provide a `rt_name` value from the following: Red, Blue, Brown"
  )
  
  route3 <- route$new("Blue")
  expect_error(
    route3$rt_code <- "fake_code",
    regexp = "rt_code is read-only"
  )
  
  expect_error(
    route3$rt_name <- "fake_name",
    regexp = "rt_name is read-only"
  )
})
