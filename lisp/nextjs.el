(projectile-project-root)

(defun nextjs/build-path(filename)
  filename
  (concat (projectile-project-root) "frontend/pages/" filename))


(defun nextjs/create-file(pagename)
  (let (
        (newbuf (generate-new-buffer-name pagename))
        (path (nextjs/build-path pagename))
        )
    (if (file-exists-p path)
        (message (concat "file exists: " path))
      (progn
        (write-region "" nil path) ; crate new file with no contenta at path
        (find-file path))))

(defun nextjs/new-page(pagename)
  "creates a new page in NextJS"
  (interactive (list (read-from-minibuffer "Page name: " `(,".js" . 1) nil nil nil)))
  (nextjs/create-file pagename))
