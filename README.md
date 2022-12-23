# lilypond-bending-additions

You can use the file [bending-additions.ily](bending-additions.ily) in this repository with LilyPond v2.24.0 or later to customize bent grace notes using a `Bent_grace_engraver`. For example, running:

```sh
lilypond --output=bending-additions --svg - <<EOS
\version "2.24.0"
\include "bending-additions.ily"
\paper {
  page-breaking = #ly:one-line-auto-height-breaking
  top-margin = 0
  left-margin = 0
  right-margin = 0
  oddFooterMarkup= ##f
}
\layout {
  \context { \TabVoice \consists #Bent_grace_engraver }
  \context { \Voice \consists #Bent_grace_engraver }
}
\pointAndClickOff
music = \relative {
  \grace c'8 \^ d4
  \grace c8\preBend \^ \afterGrace d4 \^ c8
}
\score {
  <<
    \new Staff { \clef "treble_8" \music }
    \new TabStaff \music
  >>
}
EOS
```

will output:

<img src="bending-additions.svg">
