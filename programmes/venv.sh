#!/usr/bin/env bash

uv venv venv/
source venv/bin/activate
uv pip install wordcloud nltk sudachipy sudachidict_core
