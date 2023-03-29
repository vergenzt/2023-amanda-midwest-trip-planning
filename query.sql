select
  *,
  bar(from_price, 0, max(from_price) over (), 20) as bar
from
  (
    select
      len(
        list_filter(
          list(row("start date", location)) over (
            order by
              "start date" range between 1 preceding
              and 1 following
          ),
          row -> (
            row."start date" != "start date" and
            row.location != location
          )
        )
      )
      as nearby_games,

      "start date",
      left(dayname("start date"), 3) as dow,
      "start time",
      "subject",
      "location"

    from
      (
        select * from 'data/whitesox-home.csv'
        union
        select * from 'data/cubs-home.csv'
      )
  )
  join 'data/google-flights.ndjson' on
    "start date" = fly_there_date + 1
where
  nearby_games >= 1
order by
  fly_there_date asc
