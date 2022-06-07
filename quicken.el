;;; quicken.el --- Speed up Emacs initialization -*- lexical-binding: t; -*-

;; Author: Fox Kiester <noctuid@pir-hana.cafe>
;; URL: https://github.com/emacs-magus/quicken
;; Created: June 06, 2022
;; Keywords: convenience startup speed config dotemacs
;; Package-Requires: ((emacs "24.3"))
;; Version: 0.1.0

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Speed up Emacs initialization.
;;

;; For more information see the README in the online repository.

;;; Code:
(require 'cl-lib)

(defvar quicken-gc-cons-threshold-backup nil
  "Variable to hold a backup of `gc-cons-threshold'.")

(defvar quicken-file-name-handler-alist-backup nil
  "Variable to hold a backup of `file-name-handler-alist'.
This will be merged with `file-name-handler-alist' after initialization.")

;; https://www.reddit.com/r/emacs/comments/8cpkc3/emacs_lite_just_the_essentials_config_in_200_lines/dxhhnfc/
;; https://www.reddit.com/r/emacs/comments/83l1g1/creating_a_quicker_startup_in_a_fashion_like/dwe41y7/
(defun quicken-teardown ()
  "Undo changes made in `quicken-setup'.
If `gc-cons-threshold' was not changed during initialization, revert it to what
it was before.  Reset `file-name-handler-alist' by merging the backed up
value with the current value."
  (setq file-name-handler-alist (cl-union quicken-file-name-handler-alist-backup
                                          file-name-handler-alist
                                          :test #'equal))
  (when (= gc-cons-threshold most-positive-fixnum)
    (setq gc-cons-threshold quicken-gc-cons-threshold-backup))
  (setq quicken-file-name-handler-alist-backup nil
        quicken-gc-cons-threshold-backup nil))

(defun quicken-setup ()
  "Set up some hacks to speed up Emacs initialization.
- Set `gc-cons-threshold' to be very high
- Unset `file-name-handler-alist' until after initialization

Altering `file-name-handler-alist' should be done with some caution.  Unlike
Doom at the time of writing, quicken will merge the old
`file-name-handler-alist' with the new value after initialization, so any
customization of it done during initialization will be preserved rather than
clobbered."
  (setq quicken-gc-cons-threshold-backup gc-cons-threshold
        quicken-file-name-handler-alist-backup file-name-handler-alist)
  (setq gc-cons-threshold most-positive-fixnum
        file-name-handler-alist nil)
  (add-hook 'emacs-startup-hook #'quicken-teardown)
  ;; TODO is this useful or necessary?
  ;; (add-hook 'desktop-save-mode-hook #'quicken-restore-file-name-handler-alist)
  )

(provide 'quicken)
;;; quicken.el ends here
