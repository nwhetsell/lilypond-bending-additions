\version "2.22.0"

grace-startBend = #(define-music-function (music) (ly:music?)
#{
  $(add-grace-property 'Voice 'TabNoteHead 'font-size '-2)
  \grace {
    #music \startBend
  }
  $(add-grace-property 'Voice 'TabNoteHead 'font-size '-4)
#})

% From http://lsr.di.unimi.it/LSR/Item?id=186
#(define (parenthesize-callback callback)
   (define (parenthesize-stencil grob)
     (let* ((fn (ly:grob-default-font grob))
            (pclose (ly:font-get-glyph fn "accidentals.rightparen"))
            (popen (ly:font-get-glyph fn "accidentals.leftparen"))
            (subject (callback grob))
            ;; get position of stem
            (stem-pos (ly:grob-property grob 'stem-attachment))
            ;; remember old size
            (subject-dim-x (ly:stencil-extent subject X))
            (subject-dim-y (ly:stencil-extent subject Y)))

       ;; add parens
       (set! subject
             (ly:stencil-combine-at-edge
              (ly:stencil-combine-at-edge subject X RIGHT pclose 0)
              X LEFT popen 0))

       ;; adjust stem position
       (set! (ly:grob-property grob 'stem-attachment)
             (cons (- (car stem-pos) 0.43) (cdr stem-pos)))

       ;; adjust size
       (ly:make-stencil
        (ly:stencil-expr subject)
        (interval-widen subject-dim-x 0.5)
        subject-dim-y)))

   parenthesize-stencil)

bent-grace = #(define-music-function (music) (ly:music?)
#{
  $(add-grace-property 'Voice 'TabNoteHead 'font-size '-2)
  \grace {
    \override Stem.stencil = ##f
    \override Flag.stencil = ##f
    \override NoteHead.no-ledgers = ##t
    \override NoteHead.stencil = #(parenthesize-callback ly:note-head::print)

    #music

    \revert Stem.stencil
    \revert Flag.stencil
    \revert NoteHead.no-ledgers
    \revert NoteHead.stencil
  }
  $(add-grace-property 'Voice 'TabNoteHead 'font-size '-4)
#})

afterGrace-stopBend = #(define-music-function (music) (ly:music?)
#{
  \override Stem.stencil = ##f
  \override Flag.stencil = ##f
  \override Accidental.stencil = ##f
  \override NoteHead.no-ledgers = ##t
  \override NoteHead.stencil = #(parenthesize-callback ly:note-head::print)
  \override NoteHead.transparent = ##t

  #music \stopBend

  \revert Stem.stencil
  \revert Flag.stencil
  \revert Accidental.stencil
  \revert NoteHead.no-ledgers
  \revert NoteHead.stencil
  \revert NoteHead.transparent
#})
