\version "2.24.0"

#(define (Bent_grace_engraver context)
  (let (
      (is-bending #f)
      (bend-style '())
      (was-bending #f)
      (tab-note-heads '())
      (note-heads '())
      (accidentals '())
      (stem '())
      (flag '()))

    (make-engraver
      (listeners
        ((bend-span-event engraver event)
          (set! is-bending #t)
          (set! bend-style (ly:assoc-get 'style (ly:prob-property event 'tweaks)))))

      (acknowledgers
        ((accidental-interface engraver grob source-engraver)
          (set! accidentals (cons grob accidentals)))
        ((flag-interface engraver grob source-engraver)
          (set! flag grob))
        ((note-head-interface engraver grob source-engraver)
          (let (
              (grob-name (grob::name grob)))
            (cond
              ((eq? grob-name 'NoteHead) (set! note-heads (cons grob note-heads)))
              ((eq? grob-name 'TabNoteHead) (set! tab-note-heads (cons grob tab-note-heads))))))
        ((stem-interface engraver grob source-engraver)
          (set! stem grob)))

      ((stop-translation-timestep engraver)
        (unless (eqv? (ly:moment-grace (ly:context-current-moment context)) 0)
          (if is-bending
            (unless was-bending
                (for-each
                  (lambda (tab-note-head)
                    (ly:grob-set-property! tab-note-head 'font-size -2))
                  tab-note-heads)
                (when (eq? bend-style 'pre-bend)
                    (for-each
                      (lambda (note-head)
                        (ly:grob-set-property! note-head 'no-ledgers #t)
                        (ly:grob-set-property! note-head 'stencil (parenthesize-stencil (ly:grob-property note-head 'stencil) 0.05 0.15 0.4 0.13)))
                      note-heads)
                    (unless (null? stem)
                      (ly:grob-set-property! stem 'stencil #f))
                    (unless (null? flag)
                      (ly:grob-set-property! flag 'stencil #f))))
          ; else
            (when was-bending
                (for-each
                  (lambda (note-head)
                    (ly:grob-set-property! note-head 'no-ledgers #t)
                    (ly:grob-set-property! note-head 'transparent #t))
                  note-heads)
                (for-each
                  (lambda (accidental)
                    (ly:grob-set-property! accidental 'stencil #f))
                  accidentals)
                (unless (null? stem)
                  (ly:grob-set-property! stem 'stencil #f))
                (unless (null? flag)
                  (ly:grob-set-property! flag 'stencil #f)))))

        (set! was-bending is-bending)
        (set! is-bending #f)
        (set! bend-style '())
        (set! tab-note-heads '())
        (set! note-heads '())
        (set! accidentals '())
        (set! stem '())
        (set! flag '())))))
