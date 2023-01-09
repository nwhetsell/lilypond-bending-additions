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
        (if (not (eqv? (ly:moment-grace (ly:context-current-moment context)) 0))
          (if is-bending
            (if (not was-bending)
              (begin
                (for-each
                  (lambda (tab-note-head)
                    (ly:grob-set-property! tab-note-head 'font-size -2))
                  tab-note-heads)
                (if (eq? bend-style 'pre-bend)
                  (begin
                    (for-each
                      (lambda (note-head)
                        (ly:grob-set-property! note-head 'no-ledgers #t)
                        (ly:grob-set-property! note-head 'stencil (parenthesize-callback ly:note-head::print)))
                      note-heads)
                    (if (not (null? stem))
                      (ly:grob-set-property! stem 'stencil #f))
                    (if (not (null? flag))
                      (ly:grob-set-property! flag 'stencil #f))))))
            (if was-bending
              (begin
                (for-each
                  (lambda (note-head)
                    (ly:grob-set-property! note-head 'no-ledgers #t)
                    (ly:grob-set-property! note-head 'transparent #t))
                  note-heads)
                (for-each
                  (lambda (accidental)
                    (ly:grob-set-property! accidental 'stencil #f))
                  accidentals)
                (if (not (null? stem))
                  (ly:grob-set-property! stem 'stencil #f))
                (if (not (null? flag))
                  (ly:grob-set-property! flag 'stencil #f))))))

        (set! was-bending is-bending)
        (set! is-bending #f)
        (set! bend-style '())
        (set! tab-note-heads '())
        (set! note-heads '())
        (set! accidentals '())
        (set! stem '())
        (set! flag '())))))

% From https://lsr.di.unimi.it/LSR/Item?id=186
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
