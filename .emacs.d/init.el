;; -*-Emacs-Lisp-*-
;; デバッグ時は以下をコメントアウト
;; (setq debug-on-error t)

;; ----------------------------------------------------------------
;; @general

;; スタートアップ非表示
(setq inhibit-startup-screen t)

;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; load-path で ~/.emacs.d とか書かなくてよくなる
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; ロードパスの設定
(setq load-path (cons "elisp" load-path))

;; パッケージの追加
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; パッケージリスト
(defvar package-list
  '(ace-jump-mode
    ace-isearch
    auto-compile
    auto-complete
    c-eldoc
    cmake-ide
    cmake-mode
    company-irony
    company-irony-c-headers
    company-racer
    company-rtags
    easy-kill
    elscreen
    flycheck
    flycheck-irony
    flycheck-rust
    helm
    helm-c-yasnippet
    helm-flycheck
    helm-git-grep
    helm-rtags
    helm-swoop
    highlight-symbol
    hiwin
    irony
    irony-eldoc
    madhat2r-theme
    magit
    magit-lfs
    monokai-theme
    multi-term
    quickrun
    racer
    rtags
    rust-mode
    smartparens
    undo-tree
    undohist
    yasnippet)
  "packages to be installed")

;; パッケージの自動インストール
(unless package-archive-contents (package-refresh-contents))
(dolist (pkg package-list)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; 終了時にオートセーブファイルを削除する
(setq delete-auto-save-files t)

;; auto revert buffer
(global-auto-revert-mode 1)

;; 保存時に行末の空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; -----------------------------------------------------------------
;; @visual

;; theme
;;(load-theme 'madhat2r t)
;;(load-theme 'atom-dark t)
(load-theme 'monokai )t

;; background
;; (add-hook 'tty-setup-hook
;;           '(lambda ()
;;              (set-terminal-parameter nil 'background-mode 'light)))

;; ツールバー非表示
(tool-bar-mode -1)

;; メニューバーを非表示
(menu-bar-mode -1)

;; スクロールバー非表示
(set-scroll-bar-mode nil)

;; 現在のwindowを強調
(require 'hiwin)
(hiwin-activate)
(set-face-background 'hiwin-face "gray20")


;; 現在行を目立たせる
(global-hl-line-mode t)
;; 下線
;;(setq hl-line-face 'underline)


; 1行ずつスクロール
(setq scroll-conservatively 35
      scroll-margin 20
      scroll-step 1)
(setq comint-scroll-show-maximum-output t) ;; shell-mode

;; カーソルの点滅をオフにする
(blink-cursor-mode 0)

;;; 対応する括弧を光らせる。
(show-paren-mode 1)
;;; ウィンドウ内に収まらないときだけ括弧内も光らせる。
(setq show-paren-style 'mixed)

;;関数名表示
(which-function-mode 1)

;; gdb
(setq gdb-many-windows t)

;;;; X-Window 版の場合
(cond ((eq window-system 'x)
        ;DEL キーの設定
       (define-key function-key-map [delete] [8])
       (put 'delete 'ascii-character 8)
      ;(menu-bar-mode 0)  ;メニューバーを消す
       (scroll-bar-mode -1)  ;スクロールバーを消す
       (load "hilit19")  ;face を利用
       ))

;;; DEL と BS を入れ換える
;(load "term/keyswap")
;(global-set-key "￥C-h" 'delete-backward-char)
(normal-erase-is-backspace-mode 0)

;; for c-mode
(defun my-c-mode-common-hook ()
  (c-set-style "stroustrup")
  (c-set-style "linux")
  (setq c-basic-offset 4)
  (setq c-indent-level 4)
  (c-set-offset 'innamespace 0)
  (c-set-offset 'inline-close 0)
  (c-set-offset 'inline-open 0)
  )
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(setq-default indent-tabs-mode nil)
(setq-default next-line-add-newlines nil)
;; ヘッダファイル(.h)をc++モードで開く
(setq auto-mode-alist
      (append '(("\\.h$" . c++-mode))
              auto-mode-alist))


;;; set key [お好きなように]
(global-set-key "\C-x\j" 'goto-line)
;(global-set-key "\M-/" 'auto-fill-mode)
(global-set-key "\M-r" 'redraw-display)
(global-set-key "\C-x\C-[" 'repeat-complex-command)
(global-set-key "\C-x\C-r" 'replace-string)
(global-set-key "\C-x\C-l" 'revert-buffer)
(global-set-key "\C-c\C-d" 'gdb)
(global-set-key "\C-c\C-c" 'comment-or-uncomment-region)

(setq windmove-wrap-around t)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;;; 漢字コードの設定
(set-language-environment "Japanese")
;(setq default-buffer-file-coding-system 'iso-2022-jp)
;(set-terminal-coding-system 'iso-2022-jp)
;(set-terminal-coding-system 'euc-jp)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(setq buffer-file-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

(set-keyboard-coding-system 'utf-8)

;;; Tweak UTF-8 CJK
(cond
((< emacs-major-version 23)
(utf-translate-cjk-set-unicode-range
 '((#x00a2 . #x00a3)
   (#x00a7 . #x00a8)
   (#x00ac . #x00ac)
   (#x00b0 . #x00b1)
   (#x00b4 . #x00b4)
   (#x00b6 . #x00b6)
   (#x00d7 . #x00d7)
   (#X00f7 . #x00f7)
   (#x0370 . #x03ff)                    ; Greek and Coptic
   (#x0400 . #x04FF)                    ; Cyrillic
   (#x2000 . #x206F)                    ; General Punctuation
   (#x2100 . #x214F)                    ; Letterlike Symbols
   (#x2190 . #x21FF)                    ; Arrows
   (#x2200 . #x22FF)                    ; Mathematical Operators
   (#x2300 . #x23FF)                    ; Miscellaneous Technical
   (#x2500 . #x257F)                    ; Box Drawing
   (#x25A0 . #x25FF)                    ; Geometric Shapes
   (#x2600 . #x26FF)                    ; Miscellaneous Symbols
   (#x2e80 . #xd7a3) (#xff00 . #xffef)))
))

;; GIT
; contrib/emacs/{git.el,git-blame.el,vc-git.el} をパスの通ったところにコピー
;;(require 'git)
; ログを UTF-8 にして，git に渡す
;;(add-to-list 'process-coding-system-alist '("git" . utf-8))

;;
;; for MH-E
;;
;(setq mh-ins-buf-prefix "> ")
;(setq mh-progs "/usr/local/bin/")
;(setq mh-lib "/usr/local/lib/mh/")
;(setq mhl-formfile "mhl.noconv")
;
;(load "mime-setup")

;;
;; フェンスモードのキーバインドの例
;;
;(let (hanchar ch)
;  (setq hanchar
;	'("!" "#" "$" "%" "&" "'" "(" ")" "*" "+" "/"
;	  "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
;	  ":" ";" "<" "=" ">" "?" "@"))
;  (while (setq ch (car hanchar))
;    (its-defrule ch ch nil nil "roma-kana")
;    (setq hanchar (cdr hanchar))))
(setq use-kuten-for-period nil)
(setq use-touten-for-comma nil)
(setq enable-double-n-syntax t)



;;
;; for text-mode
;;
;; text-mode では、自動的に auto-fill-mode にする
;(setq text-mode-hook
;      '(lambda ()
;	 (auto-fill-mode 1)))
;; auto-fill-mode では、各行を 70 文字以内に詰める
(set-default 'fill-column 60)


;; -----------------------------------------------------------------
;; @packages


;; rust-mode
(setq racer-rust-src-path "/Users/akira.maruoka/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src")
(setq racer-cmd "/Users/akira.maruoka/.cargo/bin/racer")
(eval-after-load "rust-mode" '(require 'racer))

(add-hook 'rust-mode-hook
  '(lambda ()
     (racer-activate)
     (local-set-key (kbd "M-.") #'racer-find-definition)
     (local-set-key (kbd "TAB") #'racer-complete-or-indent)))


;; ace-isearch
;; (require 'ace-isearch)
;; (global-ace-isearch-mode 1)


;; undo-tree
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)


;; undohist
(require 'undohist)
(undohist-initialize)


;; smartparens
(require 'smartparens-config)
(smartparens-global-mode t)


;; highlight-symbol
(require 'highlight-symbol)
;;; ソースコードにおいてM-p/M-nでシンボル間を移動
(add-hook 'prog-mode-hook 'highlight-symbol-nav-mode)
;;; シンボル置換
(global-set-key (kbd "M-s M-r") 'highlight-symbol-query-replace)
(global-set-key (kbd "M-s h r") 'highlight-symbol-remove-all)


;; easy-kill
(require 'easy-kill)
(global-set-key (kbd "M-w") 'easy-kill)


;; magit
(require 'magit)
(require 'magit-lfs)
(global-set-key (kbd "C-x g") 'magit-status)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-diff-added ((t (:background "black" :foreground "green"))))
 '(magit-diff-added-highlight ((t (:background "white" :foreground "green"))))
 '(magit-diff-removed ((t (:background "black" :foreground "blue"))))
 '(magit-diff-removed-hightlight ((t (:background "white" :foreground "blue"))))
 '(magit-hash ((t (:foreground "red")))))


;; helm
(require 'helm)
(require 'helm-config)
(require 'helm-swoop)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.

      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)

;; (defun spacemacs//helm-hide-minibuffer-maybe ()
;;   "Hide minibuffer in Helm session if we use the header line as input field."
;;   (when (with-helm-buffer helm-echo-input-in-header-line)
;;     (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
;;       (overlay-put ov 'window (selected-window))
;;       (overlay-put ov 'face
;;                    (let ((bg-color (face-background 'default nil)))
;;                      `(:background ,bg-color :foreground ,bg-color)))
;;       (setq-local cursor-type nil))))


;; (add-hook 'helm-minibuffer-set-up-hook
;;           'spacemacs//helm-hide-minibuffer-maybe)

;;(setq helm-autoresize-max-height 0)
;;(setq helm-autoresize-min-height 20)

(defadvice helm-ff-kill-or-find-buffer-fname (around execute-only-if-exist activate)
  "Execute command only if CANDIDATE exists"
  (when (file-exists-p candidate)
    ad-do-it))

(helm-autoresize-mode 1)
(helm-mode 1)


;; helm-git-grep
(require 'helm-git-grep)
(global-set-key (kbd "C-c g") 'helm-git-grep)
;; Invoke `helm-git-grep' from isearch.
(define-key isearch-mode-map (kbd "C-c g") 'helm-git-grep-from-isearch)
;; Invoke `helm-git-grep' from other helm.
(eval-after-load 'helm
    '(define-key helm-map (kbd "C-c g") 'helm-git-grep-from-helm))


;; rtags
(require 'rtags)
(require 'company-rtags)

(setq rtags-completions-enabled t)
(setq rtags-autostart-diagnostics t)
(rtags-enable-standard-keybindings)

(require 'helm-rtags)
(setq rtags-use-helm t)

(when (require 'rtags nil 'noerror)
  (add-hook 'c-mode-common-hook
            (lambda ()
              (when (rtags-is-indexed)
                (local-set-key (kbd "M-.") 'rtags-find-symbol-at-point)
                (local-set-key (kbd "M-[") 'rtags-find-references)
                (local-set-key (kbd "M-]") 'rtags-find-symbol)
                (local-set-key (kbd "M-,") 'rtags-location-stack-back)))))


;; yasnippet
(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.emacs.d/mysnippets"  ;; 自作スニペット
        yas-installed-snippets-dir         ;; package に最初から含まれるスニペット
        ))
(define-key yas-keymap (kbd "<tab>") nil)
(yas-global-mode 1)


;; irony
(require 'irony)
(require 'company-irony)
(require 'company-irony-c-headers)

(add-hook 'c++-mode-hook 'irony-mode)
;(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))

(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)

(delete 'company-semantic company-backends)


;; company
(setq company-idle-delay 0)
(global-set-key (kbd "C-M-i") 'company-complete)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-search-map (kbd "C-n") 'company-select-next)
(define-key company-search-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "<tab>") 'company-complete-selection)
;;(define-key c-mode-map [<tab>] 'company-complete)
;;(define-key c++-mode-map [<tab>] 'company-complete)

;; color-mode
(set-face-attribute 'company-tooltip nil
                    :foreground "black" :background "lightgrey")
(set-face-attribute 'company-tooltip-common nil
                    :foreground "black" :background "lightgrey")
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "white" :background "steelblue")
(set-face-attribute 'company-tooltip-selection nil
                    :foreground "black" :background "steelblue")
(set-face-attribute 'company-preview-common nil
                    :background nil :foreground "lightgrey" :underline t)
(set-face-attribute 'company-scrollbar-fg nil
                    :background "orange")
(set-face-attribute 'company-scrollbar-bg nil
                    :background "gray40")

(add-to-list `company-backends '(company-irony-c-headers company-irony company-yasnippet))
(add-hook 'c++-mode-hook 'company-mode)
;; (global-company-mode 1)


;; flycheck
(require 'flycheck)
;; Force flycheck to always use c++11 support. We use
;; the clang language backend so this is set to clang

;; Turn flycheck on everywhere
(global-flycheck-mode)

(setq-default flycheck-disabled-checkers
	      (append flycheck-disabled-checkers
		      '(c/c++-clang)))

(add-hook 'c++-mode-hook (lambda()
                           (setq flycheck-gcc-language-standard "c++11")
                           (setq flycheck-clang-language-standard "c++11")))


;; Elscreen
(require 'elscreen)
(elscreen-set-prefix-key "\C-z")

;; 既存スクリーンのリストを要求された際、0 番が存在しているかのように偽装する
(defadvice elscreen-get-screen-list (after my-ad-elscreen-get-screenlist disable)
  (add-to-list 'ad-return-value 0))

;; スクリーン生成時に 0 番が作られないようにする
(defadvice elscreen-create (around my-ad-elscreen-create activate)
  (interactive)
  ;; 0 番が存在しているかのように偽装
  (ad-enable-advice 'elscreen-get-screen-list 'after 'my-ad-elscreen-get-screenlist)
  (ad-activate 'elscreen-get-screen-list)
  ;; 新規スクリーン生成
  ad-do-it
  ;; 偽装解除
  (ad-disable-advice 'elscreen-get-screen-list 'after 'my-ad-elscreen-get-screenlist)
  (ad-activate 'elscreen-get-screen-list))

;; スクリーン 1 番を作成し 0 番を削除 (起動時、フレーム生成時用)
(defun my-elscreen-kill-0 ()
  (when (and (elscreen-one-screen-p)
             (elscreen-screen-live-p 0))
    (elscreen-create)
    (elscreen-kill 0)))

;; フレーム生成時のスクリーン番号が 1 番になるように
(defadvice elscreen-make-frame-confs (after my-ad-elscreen-make-frame-confs activate)
  (let ((selected-frame (selected-frame)))
    (select-frame frame)
    (my-elscreen-kill-0)
    (select-frame selected-frame)))

;; 起動直後のスクリーン番号が 1 番になるように
(add-hook 'after-init-hook 'my-elscreen-kill-0)

(elscreen-start)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("3629b62a41f2e5f84006ff14a2247e679745896b5eaa1d5bcfbc904a3441b0cd" "a49760e39bd7d7876c94ee4bf483760e064002830a63e24c2842a536c6a52756" "a1289424bbc0e9f9877aa2c9a03c7dfd2835ea51d8781a0bf9e2415101f70a7e" "0b7ee9bac81558c11000b65100f29b09488ff9182c083fb303c7f13fd0ec8d2b" default)))
 '(package-selected-packages
   (quote
    (package-utils atom-dark-theme undo-tree multi-term irony-eldoc helm-swoop helm-rtags helm-git-grep helm-flycheck helm-c-yasnippet flycheck-irony elscreen company-rtags company-irony-c-headers company-irony cmake-mode cmake-ide c-eldoc auto-complete auto-compile ace-jump-mode ace-isearch))))
