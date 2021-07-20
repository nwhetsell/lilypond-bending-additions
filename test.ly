\version "2.22.0"

\include "lilypond-bend-spanner/bending.ily"
\include "bending-additions.ily"

music = {
  \grace-startBend { c'8 } d4\stopBend
  \grace c8 d4
  \grace-startBend { c8 } d4\stopBend
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

music = {
  \bent-grace c'8\preBend\startBend \afterGrace d4\stopBend\startBend { \afterGrace-stopBend c8 }
  \grace c8 d4
  \bent-grace c8\preBend\startBend \afterGrace d4\stopBend\startBend { \afterGrace-stopBend c8 }
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
