(with-eval-after-load 'flyspell
  (setq ispell-program-name "aspell"
        ;; force the English dictionary, support Camel Case spelling check (tested with aspell 0.6)
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))

  (defun js-flyspell-verify ()
    (let* ((f (get-text-property (- (point) 1) 'face)))
      ;; *whitelist*
      ;; only words with following font face will be checked
      (memq f '(js2-function-call
                js2-function-param
                js2-object-property
                font-lock-comment-face
                font-lock-variable-name-face
                font-lock-string-face
                font-lock-function-name-face))))
  (put 'js2-mode 'flyspell-mode-predicate 'js-flyspell-verify)
  (put 'rjsx-mode 'flyspell-mode-predicate 'js-flyspell-verify))

;; Enable spell checking in text mode only
(add-hook 'text-mode-hook 'flyspell-mode)

(provide 'init-flyspell)
