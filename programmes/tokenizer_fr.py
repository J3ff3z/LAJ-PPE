import os
import nltk
from nltk.tokenize import word_tokenize, sent_tokenize

nltk.download('punkt')

for dossier in ["dossiertextespropres/", "contextes/"]:
    if dossier == "dossiertextespropres/":
        sortie = "PALS/dump-fr.txt"
    else:
        sortie = "PALS/contextes-fr.txt"
    liste_tokens = []
    liste_fichiers = [f for f in os.listdir(dossier) if f[0:2] == "fr"]
    with open(sortie, "w") as w:
        for fichier in liste_fichiers:
            with open(dossier+fichier, "r") as r:
                texte = r.read()
                texte = texte.replace("\n", " ")
                phrases = sent_tokenize(texte)
                for phrase in phrases:
                    tokens = word_tokenize(phrase)
                    for token in tokens:
                        w.write(token+"\n")
                    w.write("\n")
