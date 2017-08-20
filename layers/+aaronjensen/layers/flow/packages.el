(defconst flow-packages
  '(
    (flycheck-flow :toggle (configuration-layer/package-usedp 'flycheck))
    (company-flow :toggle (configuration-layer/package-usedp 'company))
    (tern :excluded t)
    (company-tern :excluded t)))

(defun flow/init-flycheck-flow ()
  (use-package flycheck-flow
    :config
    (progn
      (flycheck-add-mode 'javascript-flow 'react-mode)
      (flycheck-add-mode 'javascript-flow 'rjsx-mode)
      (flycheck-add-next-checker 'javascript-flow 'javascript-eslint))))

(defun flow/init-company-flow ()
  (use-package company-flow
    :defer t
    :commands company-flow
    :config
    (add-to-list 'company-flow-modes 'rjsx-mode)))
