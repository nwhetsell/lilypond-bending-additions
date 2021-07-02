\version "2.22.0"

\include "lilypond-bend-spanner/bending.ily"
\include "bending-additions.ily"

music = {
  \grace-startBend c' d\stopBend
  \bent-grace c\preBend\startBend \afterGrace d4\stopBend\startBend { \afterGrace-stopBend c16 }
}

\score {
  <<
    \new Staff \relative {
      \clef "treble_8"
      \music
    }
    \new TabStaff \relative {
      \music
    }
  >>
}
