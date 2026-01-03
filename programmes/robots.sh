ENTREE="URLS/fr.txt"
SORTIE="URLS_BLACKLIST/fr.txt"

> "$SORTIE" #on écrase le contenu
> ".domaines.txt"

while read -r LINE ; do
    # on récupère seulement le nom de domaine (sans le slash)
    DOMAINE_CIBLE=$(echo "$LINE" | sed -r 's%(https?://.*\.[a-z]{2,})/.*%\1%')
    VERIF_DOUBLON=$(cat ".domaines.txt" | grep "$DOMAINE_CIBLE")
    # si on a plusieurs fois le même domaine, pas besoin de récupérer plus d'une fois le robots.txt
    if [ ! -z "$VERIF_DOUBLON" ]; then
        continue
    fi
    echo "$DOMAINE_CIBLE" >> ".domaines.txt"
    ADRESSE_ROBOTS=$(echo "$DOMAINE_CIBLE/robots.txt")
    curl --user-agent -s -o ".tmp.txt" "$ADRESSE_ROBOTS"
    USER_AGENT="Non" #par défaut on met "non"
    while read -r LINE_ROBOTS ; do
        # on essaie de prendre en compte les robots mal formés, et donc on prévoit des erreurs classiques telles que le A majucule à agent, le u minuscule à User ou bien le fait de mettre le bloc User-agent: * avant d'autres blocs (pratique courante malgré la convention de le mettre à la fin)
        if [[ "$LINE_ROBOTS" =~ [Uu]ser\-[Aa]gent: ]]; then
            #on récupère ce qui suit User-agent:, et on enlève les espaces au cas où il y en a en trop
            USER_AGENT=$(echo "$LINE_ROBOTS" | cut -d " " -f 2 | tr -s ' ')
        fi
        # si on récupère bien l'astérisque, on peut procéder. Par défaut la valeur de USER_AGENT est "Non", ce qui nous empêche bien de procéder dans le cas où le bloc User-agent: * n'est pas le dernier bloc
        if [ "$USER_AGENT" == "*" ]; then
            if [[ "$LINE_ROBOTS" =~ "Disallow:" ]]; then
                # on pourrait utiliser cut avec ":" comme séparateur mais il y a un problème avec les quelques urls qui contiennent ":", ou bien " " mais on rencontre un problème si rien n'est mis en Disallow
                URL_BLACKLIST=$(echo "$LINE_ROBOTS" | sed -rn 's/Disallow:\s(.*)/\1/p')
                # si rien n'est mis en Disallow, on ne veut surtout pas mettre le domaine cible entier dans la blacklist, cette condition est donc nécessaire
                if [ ! -z "$URL_BLACKLIST" ]; then
                    echo "$DOMAINE_CIBLE$URL_BLACKLIST" >> "$SORTIE"
                fi
            fi
        fi
    done < ".tmp.txt"
done < "$ENTREE"
rm ".domaines.txt"
rm ".tmp.txt"
