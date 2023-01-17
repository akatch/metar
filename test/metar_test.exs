defmodule MetarTest do
  use ExUnit.Case
  doctest Metar

  @cases [
    {
      "2023/01/13 15:53\nKMSN 131553Z 36010G18KT 10SM OVC029 M03/M08 A3030 RMK AO2 SLP273 T10281083\n",
      %{
        condition: "overcast",
        dewpoint_c: -8,
        phenomena: nil,
        temperature_c: -3,
        visibility_mi: 10,
        wind_bearing: 360,
        wind_gusting_kt: 18,
        wind_speed_kt: 10
      }
    },
    {
      "2023/01/09 15:55\nKRYV 091555Z AUTO 22006KT 7SM CLR M02/M04 A3009 RMK AO2 T10211045\n",
      %{
        condition: "clear",
        dewpoint_c: -4,
        phenomena: nil,
        temperature_c: -2,
        visibility_mi: 7,
        wind_bearing: 220,
        wind_gusting_kt: nil,
        wind_speed_kt: 6
      }
    },
    {
      "2023/01/12 01:26\nKMDW 120126Z 19003KT 8SM BKN021 OVC033 09/06 A2980 RMK AO2 T00890056\n",
      %{
        condition: "mostly cloudy",
        dewpoint_c: 6,
        phenomena: nil,
        temperature_c: 9,
        visibility_mi: 8,
        wind_bearing: 190,
        wind_gusting_kt: nil,
        wind_speed_kt: 3
      }
    },
    {
      "2023/01/12 00:56\nKHNB 120056Z AUTO 00000KT 4SM BR BKN036 12/12 A2984 RMK AO2 SLP105 T01170117\n",
      %{
        condition: "mostly cloudy",
        dewpoint_c: 12,
        phenomena: "mist",
        temperature_c: 12,
        visibility_mi: 4,
        wind_bearing: 0,
        wind_gusting_kt: nil,
        wind_speed_kt: 0
      }
    },
    {
      "2023/01/10 20:53\nKDFW 102053Z 21018KT 10SM BKN250 28/07 A2983 RMK AO2 PK WND 22026/2011 SLP095 T02830067 56036\n",
      %{
        condition: "mostly cloudy",
        dewpoint_c: 7,
        phenomena: nil,
        temperature_c: 28,
        visibility_mi: 10,
        wind_bearing: 210,
        wind_gusting_kt: nil,
        wind_speed_kt: 18
      }
    }
  ]

  test "METAR parsing" do
    for {input, output} <- @cases, do: assert(output == Metar.parse(input))
  end
end
