Words300
========

Test sentences for Words300. The sentences were generated by applying
[this sedscript](s.sed) to the OntoGraph sentences so:

	cat ../../tests/ontograph_ext/sentences.txt | sed -f s.sed > sentences.txt

i.e.

  - replace who/body with that/thing
  - replace humans with things
  - replace words with words that are present in the RGL lexicon
  - replace an-words with an-words
  - use animals, these pass as both things and humans (at least in English) ;)
  - does reduce the number of different words