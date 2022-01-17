(in-package :cl-user)
(defpackage :bemane
  (:use :cl)
  (:export :main)
  (:import-from :arrows :-<>)
  (:local-nicknames (:d :dexador)
                    (:l :lquery)
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
  (let* ((title (vector-pop (l:$  item "title" (text))))
         (deslashed (substitute #\_ #\/ title))
         (fn (uiop:ensure-pathname (concatenate 'string deslashed ".mp3")))
         (url (vector-pop (l:$ item "enclosure" (attr "url")))))
    (when (not (uiop:file-exists-p fn))
      (d:fetch url fn))))
