\version "2.24.0"

\include "bending-additions.ily"

\layout {
  \context {
    \TabVoice
    \consists #Bent_grace_engraver
  }
  \context {
    \Voice
    \consists #Bent_grace_engraver
  }
}

music = \relative  {
  \grace c'8 \^ d4
  \grace c8 d4
  \grace c8 \^ d4
}
\score {
  <<
    \new Staff { \clef "treble_8" \music }
    \new TabStaff \music
  >>
}

music = \relative {
  \grace c'8\preBend \^ \afterGrace d4 \^ c8
  \grace c8 d4
  \grace c8\preBend \^ \afterGrace d4 \^ c8
}
\score {
  <<
    \new Staff { \clef "treble_8" \music }
    \new TabStaff \music
  >>
}
