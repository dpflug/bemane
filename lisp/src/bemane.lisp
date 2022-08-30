(in-package :cl-user)
(defpackage :bemane
  (:use :cl)
  (:export :main)
  (:import-from :arrows :-<>)
  (:import-from :uiop :file-exists-p :ensure-pathname)
  (:import-from :lquery :$)
  (:local-nicknames (:d :dexador)
                    (:p :lparallel)))
(in-package :bemane)

(setf p:*kernel* nil)

(defun main ()
  (setf p:*kernel* (p:make-kernel 3))
  (-<> (d:get "https://www.bemadiscipleship.com/rss")
       (plump:parse)
       (clss:select "rss channel item" <>)
       (download-items)))

(defun download-items (items)
  (p:pmap 'vector #'downloader items))

(defun downloader (item)
  (let* ((title (vector-pop ($ item "title" (text))))
         (deslashed (substitute #\_ #\/ title))
         (fn (handle-title deslashed))
         (url (vector-pop ($ item "enclosure" (attr "url")))))
    (when (not (file-exists-p fn))
      (d:fetch url fn))))

(defun pad-title (title colon-position)
  ;; Zero-pad the number in the titles so Roku Media Player sorts correctly
  (let ((number (parse-integer title :end colon-position :junk-allowed t))
        (title-name (subseq title colon-position)))
    (format nil "~3,'0d~A" number title-name)))

(defun weirdo-title (title)
  ;; A couple of the titles (as of 2022-02-09) are non-numbered
  ;; We give them b-numbers, copying the website's URL scheme
  ;; and putting them in their correct place in the sequence.
  (cond ((string-equal title "“Jesus Shema”")
         (concatenate 'string "021b: " title))
        ((string-equal title "Verastikh (Hosea)")
         (concatenate 'string "049b: " title))))

(defun handle-title (title)
  (let* ((colon (search ":" title))
         (new-title (if (null colon)
                        (weirdo-title title)
                        (pad-title title colon))))
    (ensure-pathname new-title :type "mp3" :want-non-wild t)))
