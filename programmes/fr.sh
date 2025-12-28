#!/usr/bin/bash

SORTIE="tableaux/fr.html"
ENTREE="URLS/debug.txt"

echo -e "\
<html>
    <head>
        <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\"> </link>
        <meta charset=\"UTF-8\">
    </head>
    <body>
        <table class=\"table is-hoverable\">
            <thead>
                <tr>
                    <th>Numéro</th>
                    <th>Adresse</th>
                    <th>CodeHttp</th>
                    <th>UTF8?</th>
                    <th>NbDeMots</th>
                    <th>Robot.txt</th>
                    <th>Aspirations</th>
                    <th>Dumps initiaux</th>
                    <th>Dumps UTF-8</th>
                    <th>Concordancier</th>
                </tr>
            </thead>
            <tbody>" > "$SORTIE"

NB_LIGNE=0

while read -r LINE ; do
    NB_LIGNE=$(expr $NB_LIGNE + 1)

    ASPIRATION="aspirations/fr-$NB_LIGNE.txt"

    CODE_ET_ENCODAGE=$(curl --user-agent -s -L -i -o "$ASPIRATION" -w "%{http_code}\n%{content_type}" "$LINE")

    CODE=$(echo "$CODE_ET_ENCODAGE" | head -n 1)

    if [ $CODE -eq 0 ]; then
        echo -e "\
            <tr class=\"is-warning\">
                <td>$NB_LIGNE</td>
                <td>$LINE</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
                <td>ERREUR</td>
            </tr>" >> "$SORTIE"
        continue
    fi

    # ENCODAGE_POSS=$(echo "iso-8859-1|ISO-8859-1|UTF-8|utf-8")

    ENCODAGE=$(echo "$CODE_ET_ENCODAGE" | tail -n 1 | cut -d "=" -f 2)

    DUMP_INITIAL="dumps/fr-$NB_LIGNE.txt"
    cat "$ASPIRATION" | lynx -dump -stdin -nolist -nomargins -assume_charset="UTF-8" > "$DUMP_INITIAL"

    CONTEXTE="contextes/fr-$NB_LIGNE.txt"
    cat "$DUMP_INITIAL" | grep -Eo "((\s|\n|,|.)?\w+(\s|\n|,|.)?){,10}[Pp]échés?((\s|\n|,|.)?\w+(\s|\n|,|.)?){,10}.?" | sed -r 's/\^/ /' | sed -r 's/\[.*\]/ /' > "$CONTEXTE"
    NB_MOTS=$(cat "$CONTEXTE" | grep -Eo "[Pp]échés?" | wc -w)

    CONCORDANCE="concordances/fr-$NB_LIGNE.html"


    if [ -z "$ENCODAGE" ]; then
        if [ -z "$NB_MOTS" ]; then
            ENCODAGE_OU_PAS='non supporté'
            echo -e "\
                <tr class=\"is-warning\">
                    <td>$NB_LIGNE</td>
                    <td>$LINE</td>
                    <td>$CODE</td>
                    <td>$ENCODAGE_OU_PAS</td>
                    <td>ERREUR</td>
                    <td>ERREUR</td>
                    <td>ERREUR</td>
                    <td>ERREUR</td>
                    <td>ERREUR</td>
                </tr>" >> "$SORTIE"
            continue
        fi
    fi

    if [[ "$ENCODAGE" =~ ('UTF-8'|'utf-8') ]]; then
        ENCODAGE_OU_PAS="UTF-8"
    else
        ENCODAGE_OU_PAS="$ENCODAGE"
    fi

    echo -e "\
            <tr>
                <td>$NB_LIGNE</td>
                <td>$LINE</td>
                <td>$CODE</td>
                <td>$ENCODAGE_OU_PAS</td>
                <td>$NB_MOTS</td>
                <td>$ROBOT</td>
                <th><a href=$ASPIRATION>fr-$NB_LIGNE.html</th>
                <th><a href=$DUMP_INITIAL>fr-$NB_LIGNE.txt</th>
                <th><a href=$DUMP_UTF8>fr-$NB_LIGNE-UTF8.txt</th>
                <th><a href=$CONTEXTE>fr-$NB_LIGNE.txt</th>
                <th><a href=$CONCORDANCE>fr-$NB_LIGNE.txt</th>
            </tr>" >> "$SORTIE"
done  < "$ENTREE"

echo -e "\
            </tbody>
        </table>
    </body>
</html>" >> "$SORTIE"
