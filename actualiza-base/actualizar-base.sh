# Hay que bajar http://sisinta.inta.gob.ar/es/perfiles.geojson y
# extraer los ids de ahí.

# Usar jq para leer json?
# curl -s 'https://api.github.com/users/lambda' | jq -r '.name'

while read id; do
  echo
  echo Downloading $id
  curl http://sisinta.inta.gob.ar/es/perfiles/$id.csv -f -o data-raw/perfiles/$id.csv
done <actualiza-base/id-list.txt
