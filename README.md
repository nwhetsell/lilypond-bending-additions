# lilypond-bending-additions

You can use the file [bending-additions.ily](bending-additions.ily) in this repository with LilyPond v2.22.0 or later to add bent grace notes using `\grace-startBend`, `\bent-grace`, and `\afterGrace-stopBend`. For example, running:

```sh
git clone https://github.com/nwhetsell/lilypond-bend-spanner.git
lilypond --output=bending-additions --svg - <<EOS
\version "2.22.0"
\include "lilypond-bend-spanner/bending.ily"
\include "bending-additions.ily"
\paper {
  page-breaking = #ly:one-line-auto-height-breaking
  top-margin = 0
  left-margin = 0
  right-margin = 0
  oddFooterMarkup= ##f
}
\pointAndClickOff
music = {
  \grace-startBend { c'8 } d4\stopBend
  \bent-grace c8\preBend\startBend \afterGrace d4\stopBend\startBend { \afterGrace-stopBend c8 }
}
\score {
  <<
    \new Staff \relative { \clef "treble_8" \music }
    \new TabStaff \relative \music
  >>
}
EOS
```

will output:

<img src="bending-additions.svg">
