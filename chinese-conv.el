;;; chinese-conv.el --- convert simplified and traditional Chinese

;; Author: gucong <gucong43216@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License,
;; version 2, as published by the Free Software Foundation.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

;;; Commentary:

;; This file work with cconv (http://code.google.com/p/cconv/) 
;; All things are in UTF8 by default.
;;   see `chinese-conv-alist' and `chinese-conv-default-from'

;;; Code:

(defvar chinese-conv-target-alist
  '(("simplified"  "UTF8-CN")
    ("traditional" "UTF8-TW"))
  "Alist of Chinese conversion target.")

(defvar chinese-conv-program-path
  "cconv"
  "The path of cconv program")

(defvar chinese-conv-default-from
  "UTF8"
  "Default encoding of Chinese conversion source")

(defvar chinese-conv-temp-path
  "/tmp/cconv.tmp"
  "temp file for Chinese conversion")

;;;###autoload
(defun chinese-conv (str to &optional from-arg interactive-p)
  "Convert a Chinese string between simplified and traditional form.
STR is the string to convert.
TO is the target of conversion, see `chinese-conv-target-alist'.
FROM-ARG is the encoding of the source string, see `chinese-conv-default-from'"
  (interactive
   (let* ((guess (or (and transient-mark-mode mark-active
                        (buffer-substring-no-properties
                         (region-beginning) (region-end)))
                   (current-word nil t)))
          (word (read-string (format "String to convert (default: %s): " guess)
                             nil nil guess))
          (to (completing-read "Convert to: " chinese-conv-target-alist nil t)))
     (list word to nil t)))
  (let ((to-arg (cadr (assoc to chinese-conv-target-alist))))
    (if (null to-arg)
        (error "Undefined conversion target")
      (with-temp-file chinese-conv-temp-path
        (insert str "\n"))
      (let ((result
             (substring
              (shell-command-to-string
               (concat chinese-conv-program-path
                       " -f " (or from-arg chinese-conv-default-from)  " -t " to-arg " "
                       chinese-conv-temp-path))
              0 -1)))
        (if interactive-p
            (message result)
          result)))))

(provide 'chinese-conv)
