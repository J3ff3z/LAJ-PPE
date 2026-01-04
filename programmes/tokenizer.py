import os
import nltk
from nltk.tokenize import word_tokenize, sent_tokenize

nltk.download('punkt')

liste_tokens = []
liste_fichiers = os.listdir("contextes/")
with open("PALS/corpus/fr.txt", "w") as w:
    for fichier in liste_fichiers:
        with open(f"contextes/{fichier}", "r") as r:
            texte = r.read()
            texte = texte.replace("\n", " ")
            phrases = sent_tokenize(texte)
            for phrase in phrases:
                tokens = word_tokenize(phrase)
                for token in tokens:
                    w.write(token+"\n")
                w.write("\n")
