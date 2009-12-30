;;; rudel-obby-debug.el --- Debugging functions for obby backend
;;
;; Copyright (C) 2009 Jan Moringen
;;
;; Author: Jan Moringen <scymtym@users.sourceforge.net>
;; Keywords: rudel, obby, debugging
;; X-RCS: $Id:$
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses>.


;;; Commentary:
;;
;; Debugging functions for the obby backend.


;;; History:
;;
;; 0.1 - Initial version


;;; Code:
;;

(require 'eieio)

(require 'rudel-debug)

(require 'rudel-obby-util)
(require 'rudel-obby-client)


;;; Variables
;;

(defvar rudel-obby-debug-old-state nil
  "Saves state of state machines across one function call.")


;;; Functions
;;

(defmethod rudel-send :before ((this rudel-obby-connection)
			       name &rest arguments)
  "Print NAME and ARGUMENTS to debug stream."
  (let ((message (apply #'rudel-obby-assemble-message
			name arguments)))

    (with-slots (transport) this
      (rudel-debug-stream-insert
       (rudel-debug-stream-name transport)
       :sent
       (concat  (substring message 0 (min (length message) 100))
		(when (> (length message) 100)
		  "..."))
       (append (list name) arguments))))
    )

(defmethod rudel-accept :before ((this rudel-obby-connection) data)
  "Print DATA to debug stream."
  (with-slots (transport) this
    (rudel-debug-stream-insert
     (rudel-debug-stream-name transport)
     :received
     (concat (substring data 0 (min (length data) 100))
	     (when (> (length data) 100)
	       "..."))))
  )

(defmethod rudel-switch :before ((this rudel-obby-connection)
				 state &rest arguments)
  "Store name of STATE for later printing."
  (with-slots (state) this
    (setq rudel-obby-debug-old-state
	  (if state
	      (object-name-string state)
	    "#start")))
  )

(defmethod rudel-switch :after ((this rudel-obby-connection)
				state &rest arguments)
  "Print STATE and ARGUMENTS to debug stream."
  (with-slots (transport state) this
    (let ((old-state rudel-obby-debug-old-state)
	  (new-state (object-name-string state)))
      (unless (string= old-state new-state)
	(rudel-debug-stream-insert
	 (rudel-debug-stream-name transport)
	 :special
	 (if arguments
	     (format "%s -> %s %s" old-state new-state arguments)
	   (format "%s -> %s" old-state new-state))))))
  )

(provide 'rudel-obby-debug)
;; Local Variables:
;; no-byte-compile: t
;; End:
;;; rudel-obby-debug.el ends here
