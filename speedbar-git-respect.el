(require 'f)
(require 'speedbar)
(require 'vc-git)

(setq origin-file-lists (symbol-function 'speedbar-file-lists))

(defun vc-git-dir-p (directory)
  (eq 'Git (condition-case nil (vc-responsible-backend directory) (error nil))))

(defun speedbar-file-lists (directory)
  (setq origin-directory default-directory)
  (setq default-directory directory)
  (let ((result (if (vc-git-dir-p directory)                    
                    (git-file-lists directory)
                  (funcall origin-file-lists directory))))
    (setq default-directory origin-directory)
    result))

(defun git-file-lists (directory)
  (setq directory (expand-file-name directory))
  ;; find the directory, either in the cache, or build it.
  (or (and (not dframe-power-click) ;; In powerclick mode, always rescan.
           (cdr-safe (assoc directory speedbar-directory-contents-alist)))
      ;; tracked files and directory
      ;; git ls-files --directory
      ;; untracked files and directory
      ;; git ls-files --other --directory
      ;; untracked ignored
      ;; git ls-files --other --directory --ignored --exclude-standard
      (let ((tracked-fd (file-list-process (vc-git--run-command-string nil "ls-files" "--directory")))
            (untracked-fd (file-list-process (vc-git--run-command-string nil "ls-files" "--other" "--directory")))
            (untracked-ignored (file-list-process (vc-git--run-command-string nil "ls-files" "--other" "--directory" "--ignored" "--exclude-standard")))
            (dirs nil)
            (files nil))
        (setf dirs (remove-if (lambda (x) (member x (car untracked-ignored))) (car untracked-fd)))
        (setf files (remove-if (lambda (x) (member x (cadr untracked-ignored))) (cadr untracked-fd)))        
        (setf dirs (delete-dups (append (car tracked-fd) dirs)))
        (setf files (delete-dups (append (cadr tracked-fd) files)))
        (setf dirs (remove-if (lambda (x) (>= 0 (length x))) dirs))
        (setf files (remove-if (lambda (x) (>= 0 (length x))) files))
        (setf dirs (sort dirs 'string>))
        (setf files (sort files 'string>))
	(let ((nl (cons (nreverse dirs) (list (nreverse files))))
              (ae (assoc directory speedbar-directory-contents-alist)))
          (if ae (setcdr ae nl)
            (push (cons directory nl)
                  speedbar-directory-contents-alist))
	  nl))))

(defun file-directory-split (path)
  (split-string path (f-path-separator)))

(defun file-list-process (list)
  (setq list (split-string list "\n"))
  (let ((dirs nil)
        (files nil))
    (mapc (lambda (path)
            (let* ((res (file-directory-split path))
                   (name (car res)))
              (if (> (length res) 1)
                  (setq dirs (cons name dirs))
                (setq files (cons name files)))))
          list)
    (list (delete-dups dirs) files)))

(provice 'speedbar-git-respect)
