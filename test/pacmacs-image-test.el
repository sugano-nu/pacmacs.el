(ert-deftest pacmacs-load-image-test ()
  (with-mock
   (mock (create-image "pew" 'xpm nil :heuristic-mask t) => 42 :times 1)
   (should (= 42 (pacmacs-load-image "pew")))))

(ert-deftest pacmacs-insert-image-test ()
  (let ((resource "khooy")
        (resource-vector "pew"))
    (with-mock
     (mock (insert-image resource " " nil resource-vector) => 42 :times 1)
     (should (= 42 (pacmacs-insert-image resource resource-vector))))))

(ert-deftest pacmacs--put-bits-dot-test ()
  (let ((input-bits (pacmacs--construct-2d-bool-vector
                     '((nil nil nil)
                       (nil nil nil)
                       (nil nil nil))))
        (expected-bits (pacmacs--construct-2d-bool-vector
                        '((t   t   nil)
                          (t   t   nil)
                          (nil nil nil)))))
    (pacmacs--put-bits-dot input-bits 0 0 2)
    (should (equal expected-bits
                   input-bits))))

(ert-deftest pacmacs--put-vertical-bar-test ()
  (let ((input-bits (pacmacs--construct-2d-bool-vector
                     '((nil nil nil)
                       (nil nil nil)
                       (nil nil nil))))
        (expected-bits (pacmacs--construct-2d-bool-vector
                        '((t t nil)
                          (t t nil)
                          (t t nil)))))
    (pacmacs--put-vertical-bar input-bits 0 3 2)
    (should (equal (pacmacs--bits-to-lists expected-bits)
                   (pacmacs--bits-to-lists input-bits)))))

(ert-deftest pacmacs--put-horizontal-bar-test ()
  (let ((input-bits (pacmacs--construct-2d-bool-vector
                     '((nil nil nil)
                       (nil nil nil)
                       (nil nil nil))))
        (expected-bits (pacmacs--construct-2d-bool-vector
                        '((t   t   t)
                          (t   t   t)
                          (nil nil nil)))))
    (pacmacs--put-horizontal-bar input-bits 0 3 2)
    (should (equal (pacmacs--bits-to-lists expected-bits)
                   (pacmacs--bits-to-lists input-bits)))))

(ert-deftest pacmacs--bit-list-to-integer-test ()
  (let ((data '((nil         . 0)
                ((t)         . 1)
                ((t nil)     . 2)
                ((t t)       . 3)
                ((t nil nil) . 4))))
    (-each data
      (-lambda ((bit-list . number))
        (should (= number (pacmacs--bit-list-to-integer
                           bit-list)))))))

(ert-deftest pacmacs--create-wall-tile-test ()
  (with-mock
   (mock (pacmacs--bit-list-to-integer *) => 0)
   (mock (gethash * *) => nil)
   (mock (puthash * * *) => nil)
   (mock (create-image * * *) => nil)
   (mock (pacmacs--wall-tile-to-xpm [[nil t   t   t]
                                     [t   t   t   t]
                                     [t   t   t   t]
                                     [t   t   t   t]]
                                    4 4))
   (pacmacs--create-wall-tile 4 4 t t nil nil
                              nil nil nil nil)))

(ert-deftest pacmacs--wall-tile-to-xpm-test ()
  (should (string= (concat "/* XPM */\n"
                           "static char *tile[] = {\n"
                           "/**/\n\"2 2 3 1\",\n"
                           "\"  c None\",\n"
                           "\"a c #khooy1\",\n"
                           "\"b c #khooy2\",\n"
                           "/* pixels */\n"
                           "\"ab\",\n"
                           "\"b \"\n};")
                   (pacmacs--wall-tile-to-xpm [[0 1]
                                               [1 nil]]
                                              2 2
                                              '("#khooy1"
                                                "#khooy2")))))

(ert-deftest pacmacs--normalize-wall-bits-test ()
  (should (equal '(nil nil nil nil t nil t nil)
                 (pacmacs--normalize-wall-bits
                  '(nil nil nil nil t nil t nil))))
  (should (equal '(t t t t nil nil nil nil)
                 (pacmacs--normalize-wall-bits
                  '(t t t t nil t nil t))))
  (should (equal '(t t t t nil nil nil nil)
                 (pacmacs--normalize-wall-bits
                  '(t t t t t nil t nil))))
  (should (equal '(t t t t nil nil nil nil)
                 (pacmacs--normalize-wall-bits
                  '(t t t t t t t t)))))
