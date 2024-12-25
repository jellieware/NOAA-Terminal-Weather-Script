#/bin/sh
# Usage $ script zone
# Example: $ script wiz066
# $1 is the zone (wiz066)
# Starts each forecast with a "@"
# Replace ". ."  with "@" This separates the second and subsequent forecasts.
# Replace the single " ."  with "@" at the beginning of the first forecast.
# Trim the "$$" at the end of the message. 
default="maz005"
grep -A 1 "$default" "/storage/emulated/0/zones.txt" | sed -n '1p'
grep -A 1 "$default" "/storage/emulated/0/zones.txt" | sed -n '4p'
separate_forecasts () { sed -e 's|\. \.|@|g' \
                            -e 's| \.|@|g' \
                            -e 's| \$\$||g'; }                            
# Make uppercase into lowercase
# Then recapitalize the first letter in each paragraph.
# Then recapitalize the first letter in each new sentence.
# Then substitute a ":" for the "..." and capitalize the first letter.
lowercase () { tr [:upper:] [:lower:] | \
               sed -e 's|\(^[a-z]\)|\U\1|g' \
                   -e 's|\(\.\ [a-z]\)|\U\1|g' \
                   -e 's|\.\.\.\([a-z]\)|: \U\1|g'; }
State=$(echo $default | cut -c1-2)
raw_forecast=$(wget -q -O - https://tgftp.nws.noaa.gov/data/forecasts/zone/${State}/${default}.txt)
for period in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
   echo ""
   if [ ${period} -eq 1 ]; then
      header=$(echo $raw_forecast | separate_forecasts | cut -d'@' -f${period})
      header_size=$(echo $header | wc -w)
      header_zulu="$(echo $header | cut -d' ' -f4 | cut -c3-4):$(echo $header | cut -d' ' -f4 | cut -c5-6)Z"
      issue_time="$(date -d "$header_zulu" +%H:%M)"
      expire_time="$(echo $header | cut -d':' -f2 | cut -c9-10):$(echo $header | cut -d':' -f2 | cut -c11-12)"
      echo "Issue Time ${issue_time}, Expires ${expire_time}"
   else
      echo $raw_forecast | separate_forecasts | cut -d'@' -f${period} | lowercase
   fi
done
echo ""
read