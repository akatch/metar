defmodule Metar do
  @moduledoc """
  Documentation for `Metar`.
  """

  defp c_to_int(""), do: 0
  defp c_to_int("M" <> str), do: -c_to_int(str)
  defp c_to_int(str), do: String.to_integer(str)
  defp kt_to_int(""), do: nil
  defp kt_to_int(str), do: String.to_integer(str)

  defp translate_condition(c) do
    case c do
      c when c in ["CLR", "SKC"] -> "clear"
      "FEW" -> "partly cloudy"
      "SCT" -> "cloudy"
      "BKN" -> "mostly cloudy"
      "OVC" -> "overcast"
      "VV" -> "vertical visibility"
      "" -> false
    end
  end

  defp translate_quality(quality) do
    case quality do
      "+" -> "heavy"
      "-" -> "light"
      "VC" -> "vicinity"
      "" -> nil
    end
  end

  defp translate_other(other) do
    case other do
      "SQ" -> "squall"
      "SS" -> "sandstorm"
      "FC" -> "tornado"
      "DS" -> "dust storm"
      "PO" -> "sand whirls"
      "" -> nil
    end
  end

  defp translate_description(description) do
    case description do
      "MI" -> "shallow"
      "BL" -> "blowing"
      "BC" -> "patchy"
      "SH" -> "showers"
      "PR" -> "partial"
      "DR" -> "drifting"
      "TS" -> "thunderstorms"
      "FZ" -> "freezing"
      "" -> nil
    end
  end

  defp translate_precipitation(precipitation) do
    case precipitation do
      "DZ" -> "drizzle"
      "IC" -> "ice crystals"
      "UP" -> nil
      "RA" -> "rain"
      "PL" -> "ice pellets"
      "SN" -> "snow"
      "GR" -> "hail"
      "SG" -> "snow grains"
      "GS" -> "small hail"
      "" -> nil
    end
  end

  defp translate_obscurity(obscurity) do
    case obscurity do
      "BR" -> "mist"
      "SA" -> "sand"
      "FU" -> "smoke"
      "FG" -> "fog"
      "HZ" -> "haze"
      "VA" -> "volcanic ash"
      "PY" -> "spray"
      "DU" -> "dust"
      "" -> nil
    end
  end

  defp translate_phenomena(quality, description, precipitation, obscurity, other) do
    phenomena =
      Enum.reject(
        [
          translate_quality(quality),
          translate_description(description),
          translate_precipitation(precipitation),
          translate_obscurity(obscurity),
          translate_other(other)
        ],
        &is_nil/1
      )

    cond do
      length(phenomena) > 0 ->
        Enum.join(phenomena, " ")

      true ->
        nil
    end
  end

  @doc """
  Parse a METAR string.

  ## Regex101
  # https://regex101.com/r/ksSWUy/1

  ## Examples

  iex> Metar.parse("2023/01/13 15:53 KMSN 131553Z 36010G18KT 10SM OVC029 M03/M08 A3030 RMK AO2 SLP273 T10281083")
  %{
    altitude: 3030,
    condition: "overcast",
    dewpoint_c: -8,
    lastmod: 131553,
    phenomena: nil,
    remarks: "A02 SLP273 T102810I3",
    station: "KMSN",
    temperature_c: -3,
    visibility_mi: 10,
    wind_bearing: 360,
    wind_gusting_kt: 18,
    wind_speed_kt: 10
  }

  """
  def parse(metar) do
    %{
      "altitude" => a,
      "condition" => c,
      "dewpoint" => dp,
      "gusting" => g,
      "quality" => qual,
      "description" => desc,
      "precipitation" => prec,
      "obscurity" => obs,
      "other" => oth,
      "lastmod" => l,
      "remarks" => r,
      "station" => s,
      "temperature" => t,
      "visibility" => v,
      "wind_speed" => ws,
      "wind_direction" => wd
    } =
      Regex.named_captures(
        ~r/(?<station>[A-Z]{4})\s(?<lastmod>\d{6})Z(?:.*)(?<wind_direction>\d{3})(?<wind_speed>\d{2})(?:G(?<gusting>\d{2}))?KT(?:.*)(?<visibility>\d+(?:\s+\d+\/\d+)?)(?:SM)?(?:\s(?<quality>\+|-|VC)?(?<description>MI|BL|BC|SH|PR|DR|TS|FZ)?(?<precipitation>DZ|IC|UP|RA|PL|SN|GR|SG|GS)?(?<obscurity>BR|SA|FU|HZ|VA|PY|DU|FG)?(?<other>SQ|FC|SS|DS|PO)?)?\s(?<condition>CLR|SKC|FEW|SCT|BKN|OVC|VV)(?:\d{3})?(?:.*)?\s(?:(?<temperature>M?(\d{2}))\/(?<dewpoint>M?(\d{2}))?\s)?A(?<altitude>\d+)\sRMK\s(?<remarks>.*)\\n/,
        metar
      )

    %{
      altitude: String.to_integer(a),
      condition: translate_condition(c),
      dewpoint_c: c_to_int(dp),
      lastmod: l,
      phenomena: translate_phenomena(qual, desc, prec, obs, oth),
      remarks: r,
      station: s,
      temperature_c: c_to_int(t),
      visibility_mi: String.to_integer(v),
      wind_bearing: String.to_integer(wd),
      wind_gusting_kt: kt_to_int(g),
      wind_speed_kt: kt_to_int(ws)
    }
  end
end
