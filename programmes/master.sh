#!/usr/bin/bash

if [ $# -eq 0 ];
then
    echo "indiquez une langue"
    exit 1
fi

LANGUE="$1"

SORTIE="tableaux/array-$LANGUE.html"
ENTREE="URLS/fr.txt"

echo -e "\
        <table class=\"table is-hoverable\">
            <thead>
                <tr>
                    <th>Numéro</th>
                    <th>Adresse</th>
                    <th>CodeHttp</th>
                    <th>UTF8?</th>
                    <th>NbDeMots</th>
                    <td>Nombre d'apparition du mot</td>
                    <th>Robot.txt</th>
                    <th>Aspirations</th>
                    <th>Dumps initiaux</th>
                    <th>Dumps clean</th>
                    <th>Concordancier</th>
                </tr>
            </thead>
            <tbody>" > "$SORTIE"

NB_LIGNE=0

while read -r LINE ; do
    NB_LIGNE=$(expr $NB_LIGNE + 1)
    echo "Working on line $NB_LIGNE"
    ASPIRATION="aspirations/$LANGUE-$NB_LIGNE.txt"

    CODE_ET_ENCODAGE=$(curl -s -L -i -o "$ASPIRATION" -w "%{http_code}\n%{content_type}" "$LINE")

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
                <td>ERREUR</td>
            </tr>" >> "$SORTIE"
        continue
    fi

    # ENCODAGE_POSS=$(echo "iso-8859-1|ISO-8859-1|UTF-8|utf-8")

    ENCODAGE=$(echo "$CODE_ET_ENCODAGE" | tail -n 1 | cut -d "=" -f 2)

    DUMP_INITIAL="dumps/$LANGUE-$NB_LIGNE.txt"
    cat "$ASPIRATION" | lynx -dump -stdin -nolist -nomargins -assume_charset="UTF-8" > "$DUMP_INITIAL"

    CONTEXTE="contextes/$LANGUE-$NB_LIGNE.txt"
    CONCORDANCE="concordances/$LANGUE-$NB_LIGNE.html"

    CLEAN=$(bash programmes/scriptnettoyage1.sh "$DUMP_INITIAL")
    CLEAN=${CLEAN:1}
    NB_MOTS=$(cat "$CLEAN" | wc -w)
    COUNT=$(bash programmes/comptage_occurence_script.sh "$CLEAN")

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
                <td>$COUNT</td>
                <td>$ROBOT</td>
                <th><a href=\"../$ASPIRATION\">$LANGUE-$NB_LIGNE.html</th>
                <th><a href=\"../$DUMP_INITIAL\">$LANGUE-$NB_LIGNE.txt</th>
                <th><a href=\"../$DUMP_UTF8\">$LANGUE-$NB_LIGNE-UTF8.txt</th>
                <th><a href=\"../$CONTEXTE\">$LANGUE-$NB_LIGNE.txt</th>
                <th><a href=\"../concordancier.html?f=$(basename $CONTEXTE)\">$LANGUE-$NB_LIGNE.txt</th>
            </tr>" >> "$SORTIE"
done  < "$ENTREE"

echo -e "\
            </tbody>
        </table>" >> "$SORTIE"
echo "Done"
