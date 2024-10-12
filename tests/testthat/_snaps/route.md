# Base route generates with no trains

    Code
      route1
    Output
      CTA Train Route
      Name: Brown
      Code: Brn
      

# Route get_positions works correctly

    Code
      jsonlite::toJSON(route2$trains, auto_unbox = TRUE, pretty = TRUE)
    Output
      [
        {
          "run": 312,
          "dest": "30114",
          "dest_name": "Loop",
          "dir": "1",
          "dir_cardinal": "N",
          "next_station": "40150",
          "next_station_nm": "Pulaski",
          "next_stop": "30028",
          "pred_updated": "2024-10-11 20:58:30",
          "pred_arrival": "2024-10-11 21:00:30",
          "due": false,
          "delayed": false,
          "coord": ["41.85375", "-87.73326"],
          "degrees": 88,
          "time_to_arrival": 1
        },
        {
          "run": 313,
          "dest": "30114",
          "dest_name": "54th/Cermak",
          "dir": "1",
          "dir_cardinal": "N",
          "next_station": "41510",
          "next_station_nm": "Morgan",
          "next_stop": "30296",
          "pred_updated": "2024-10-11 20:58:26",
          "pred_arrival": "2024-10-11 20:59:26",
          "due": true,
          "delayed": false,
          "coord": ["41.8857", "-87.64178"],
          "degrees": 269,
          "time_to_arrival": "DUE"
        },
        {
          "run": 314,
          "dest": "30114",
          "dest_name": "Loop",
          "dir": "5",
          "dir_cardinal": "S",
          "next_station": "41160",
          "next_station_nm": "Clinton",
          "next_stop": "30221",
          "pred_updated": "2024-10-11 20:58:34",
          "pred_arrival": "2024-10-11 21:00:34",
          "due": false,
          "delayed": false,
          "coord": ["41.88531", "-87.66697"],
          "degrees": 88,
          "time_to_arrival": 1
        },
        {
          "run": 315,
          "dest": "30114",
          "dest_name": "54th/Cermak",
          "dir": "5",
          "dir_cardinal": "S",
          "next_station": "40440",
          "next_station_nm": "California",
          "next_stop": "30087",
          "pred_updated": "2024-10-11 20:58:57",
          "pred_arrival": "2024-10-11 20:59:57",
          "due": true,
          "delayed": false,
          "coord": ["41.8544", "-87.68513"],
          "degrees": 269,
          "time_to_arrival": "DUE"
        }
      ] 

---

    Code
      route2
    Output
      CTA Train Route
      Name: Pink
      Code: Pink
      Trains on route: 4
      Last updated: 2024-10-11 20:59:17 US/Central

