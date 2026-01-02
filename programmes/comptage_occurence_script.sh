#!/bin/bash

if [ $# -eq 0 ]; 
then 
    echo "indiquez un fichier" 
    exit 1 
fi 

fichier="$1"

SORTIE="concordances/$(basename "$1").html"

pattern='\b((grzech(u|owi|em|y|om|ami|ach|ów)?)|(péché)s?)|(大?罪)\b'
sentences=$(sed 's/[.!?。…！？«»「」]/\n/g' "$fichier")

count=0

echo -e "<table class=\"table is-hoverable\">
            <thead>
                <tr>
                    <th>Avant</th>
                    <th>Mot</th>
                    <th>Apres</th>
                </tr>
            </thead>" >> "$SORTIE"

while IFS= read -r line; do
    reste="$line"
    while echo "$reste" | grep -qiE "$pattern"; do
        count=$((count + 1))
        word=$(echo "$reste" | grep -oiE "$pattern" | head -n 1)
        before=$(echo "$reste" | sed -E "s/($word).*//I")
        after=$(echo "$reste" | sed -E "s/^.*$before$word(.*)/\1/I")

        echo -e "<tr>
                    <td>$before</td>
                    <td>$word</td>
                    <td>$after</td>
                </tr>" >> "$SORTIE"
        
        reste="$after"
    done
done <<< "$sentences"


echo $count