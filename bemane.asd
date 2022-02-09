(defsystem bemane
  :version "0.1"
  :author "David Pflug"
  :mailto "david@pflug.io"
  :homepage "https://pflug.io"
  :source-control (:git "ssh://git@pflug.io:d/bemane.git")
  :license "GNU AGPLv3"
  :defsystem-depends-on ()
  :depends-on (:dexador :lquery :lparallel :arrows :uiop)
  :pathname "src"
  :components ((:file "bemane"))
  :description "Short script to keep a dir of BEMA episodes up-to-date"
  :build-operation "program-op"
  :build-pathname "bemane"
  :entry-point "bemane:main")
