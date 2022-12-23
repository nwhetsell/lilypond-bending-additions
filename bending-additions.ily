\version "2.24.0"

#(define (Bent_grace_engraver context)
  (let (
      (is-bending #f)
      (was-bending-one-timestep-ago #f)
      (was-bending-two-timesteps-ago #f)
      (current-accidental '())
      (previous-accidental '())
      (current-bend '())
      (previous-bend '())
      (current-bend-style '())
      (previous-bend-style '())
      (current-flag '())
      (previous-flag '())
      (current-note-head '())
      (previous-note-head '())
      (current-stem '())
      (previous-stem '())
      (current-tab-note-head '())
      (previous-tab-note-head '()))

    (make-engraver
      (listeners
        ((note-event engraver event)
          (set! is-bending (event-has-articulation? 'bend-span-event event))
          (if is-bending
            (for-each
              (lambda (articulation)
                (set! current-bend-style (ly:assoc-get 'style (ly:prob-property articulation 'tweaks))))
              (ly:prob-property event 'articulations)))))

      (acknowledgers
        ((accidental-interface engraver grob source-engraver)
          (set! current-accidental grob))
        ((bend-interface engraver grob source-engraver)
          (set! current-bend grob))
        ((flag-interface engraver grob source-engraver)
          (set! current-flag grob))
        ((note-head-interface engraver grob source-engraver)
          (let (
              (grob-name (grob::name grob)))
            (cond
              ((eq? grob-name 'NoteHead) (set! current-note-head grob))
              ((eq? grob-name 'TabNoteHead) (set! current-tab-note-head grob)))))
        ((stem-interface engraver grob source-engraver)
          (set! current-stem grob)))

      ((stop-translation-timestep engraver)
        (if (not (null? previous-note-head))
          (let (
              (moment (grob::when previous-note-head)))
            (if (and (not (null? moment)) (not (eq? (ly:moment-grace moment) 0)))
              (if was-bending-one-timestep-ago
                (if (not was-bending-two-timesteps-ago)
                  (if (eq? previous-bend-style 'pre-bend)
                    (begin
                      (ly:grob-set-property! previous-note-head 'no-ledgers #t)
                      (ly:grob-set-property! previous-note-head 'stencil (parenthesize-callback ly:note-head::print))
                      (if (not (null? previous-flag))
                        (ly:grob-set-property! previous-flag 'stencil #f))
                      (if (not (null? previous-stem))
                        (ly:grob-set-property! previous-stem 'stencil #f)))))
                (if was-bending-two-timesteps-ago
                  (begin
                    (ly:grob-set-property! previous-note-head 'no-ledgers #t)
                    (ly:grob-set-property! previous-note-head 'transparent #t)
                    (if (not (null? previous-accidental))
                      (ly:grob-set-property! previous-accidental 'stencil #f))
                    (if (not (null? previous-flag))
                      (ly:grob-set-property! previous-flag 'stencil #f))
                    (if (not (null? previous-stem))
                      (ly:grob-set-property! previous-stem 'stencil #f))))))))

        (if (not (null? previous-tab-note-head))
          (let (
              (moment (grob::when previous-tab-note-head)))
            (if (and (not (null? moment)) (not (eq? (ly:moment-grace moment) 0)))
              (if was-bending-one-timestep-ago
                (if (not was-bending-two-timesteps-ago)
                  (ly:grob-set-property! previous-tab-note-head 'font-size -2))))))

        (set! was-bending-two-timesteps-ago was-bending-one-timestep-ago)
        (set! was-bending-one-timestep-ago is-bending)
        (set! is-bending #f)
        (set! previous-accidental current-accidental)
        (set! current-accidental '())
        (set! previous-bend current-bend)
        (set! current-bend '())
        (set! previous-bend-style current-bend-style)
        (set! current-bend-style '())
        (set! previous-flag current-flag)
        (set! current-flag '())
        (set! previous-note-head current-note-head)
        (set! current-note-head '())
        (set! previous-stem current-stem)
        (set! current-stem '())
        (set! previous-tab-note-head current-tab-note-head)
        (set! current-tab-note-head '())))))

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
