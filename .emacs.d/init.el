;; -*-Emacs-Lisp-*-
;; debug
;; (setq debug-on-error t)

;; ----------------------------------------------------------------
;; @ package

;; load-path で ~/.emacs.d とか書かなくてよくなる
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; ロードパスの設定
(setq load-path (cons "elisp" load-path))

;; パッケージの追加
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; If package not found, execute the command
;; M-x package-refresh-contents

;; パッケージリスト
(defvar package-list
  '(ace-jump-mode
    ace-isearch
    anzu
    auto-compile
    auto-complete
    avy-migemo
    c-eldoc
    cmake-ide
    cmake-mode
    company-irony
    company-irony-c-headers
    counsel
    counsel-gtags
    disaster
    dumb-jump
    easy-kill
    elscreen
    free-keys
    flycheck
    flycheck-irony
    git-gutter
    helm
    helm-ag
    helm-c-yasnippet
    helm-elscreen
    helm-flycheck
    helm-git-grep
    helm-gtags
    helm-make
    helm-swoop
    highlight-symbol
    hiwin
    irony
    irony-eldoc
    ivy
    magit
    magit-lfs
    modern-cpp-font-lock
    monokai-theme
    multi-term
    multiple-cursors
    powerline
    smooth-scroll
    undo-tree
    undohist
    wgrep
    which-key
    yasnippet)
  "packages to be installed")

;; パッケージの自動インストール
(unless package-archive-contents (package-refresh-contents))
(dolist (pkg package-list)
  (unless (package-installed-p pkg)
    (package-install pkg)))


;; ----------------------------------------------------------------
;; @ general

;; スタートアップ非表示
(setq inhibit-startup-screen t)

;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; 終了時にオートセーブファイルを削除する
(setq delete-auto-save-files t)

;; バックアップファイルを作らない
(setq make-backup-files nil)
(setq backup-inhibited t)

;; auto revert buffer
(global-auto-revert-mode 1)

;; 行頭で行削除した場合に行全体を削除する
(setq kill-whole-line t)

;; 問い合わせを簡略化 yes/no を y/n
(fset 'yes-or-no-p 'y-or-n-p)

;; 保存時に行末の空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; インデントにスペースを使用する
(setq-default indent-tabs-mode nil)

;; バッファの最後で新規行を追加するのを禁止する
(setq-default next-line-add-newlines nil)

;; bufferの最後でカーソルを動かそうとしても音をならなくする
(defun next-line (arg)
  (interactive "p")
  (condition-case nil
      (line-move arg)
    (end-of-buffer)))

;; エラー音をならなくする
(setq ring-bell-function 'ignore)

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

(setq use-kuten-for-period nil)
(setq use-touten-for-comma nil)
(setq enable-double-n-syntax t)


;; -----------------------------------------------------------------
;; @ visual

;; theme
(load-theme 'monokai t)

;; ツールバー非表示
(tool-bar-mode -1)

;; メニューバーを非表示
(menu-bar-mode -1)

;; スクロールバー非表示
(set-scroll-bar-mode nil)

;; 画面分割は横を優先に
(setq split-height-threshold nil)

;; 現在のwindowを強調
(require 'hiwin)
(hiwin-activate)
(set-face-background 'hiwin-face "gray25")

;; show line number
;; (require 'linum)
;; (global-num-mode 0)

;; 現在行を目立たせる
(global-hl-line-mode t)  ;; highlight
;;(setq hl-line-face 'underline)  ;; underline

;; ; 1行ずつスクロール
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

;; リージョンのハイライト
(transient-mark-mode 1)

;;関数名表示
(which-function-mode 1)

;; git-gutter-fringe
(global-git-gutter-mode 1)

;; anzu
(global-anzu-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(anzu-deactivate-region t)
 '(anzu-mode-lighter "")
 '(anzu-search-threshold 1000)
 '(avy-migemo-function-names
   (quote
    (swiper--add-overlays-migemo
     (swiper--re-builder :around swiper--re-builder-migemo-around)
     (ivy--regex :around ivy--regex-migemo-around)
     (ivy--regex-ignore-order :around ivy--regex-ignore-order-migemo-around)
     (ivy--regex-plus :around ivy--regex-plus-migemo-around)
     ivy--highlight-default-migemo ivy-occur-revert-buffer-migemo ivy-occur-press-migemo avy-migemo-goto-char avy-migemo-goto-char-2 avy-migemo-goto-char-in-line avy-migemo-goto-char-timer avy-migemo-goto-subword-1 avy-migemo-goto-word-1 avy-migemo-isearch avy-migemo-org-goto-heading-timer avy-migemo--overlay-at avy-migemo--overlay-at-full)))
 '(custom-safe-themes
   (quote
    ("bd7b7c5df1174796deefce5debc2d976b264585d51852c962362be83932873d9" "3629b62a41f2e5f84006ff14a2247e679745896b5eaa1d5bcfbc904a3441b0cd" "a49760e39bd7d7876c94ee4bf483760e064002830a63e24c2842a536c6a52756" "a1289424bbc0e9f9877aa2c9a03c7dfd2835ea51d8781a0bf9e2415101f70a7e" "0b7ee9bac81558c11000b65100f29b09488ff9182c083fb303c7f13fd0ec8d2b" default)))
 '(package-selected-packages
   (quote
    (avy-migemo multiple-cursors clang-format package-utils atom-dark-theme undo-tree multi-term irony-eldoc helm-git-grep helm-flycheck helm-c-yasnippet flycheck-irony elscreen company-rtags company-irony-c-headers company-irony cmake-mode cmake-ide c-eldoc auto-complete auto-compile ace-jump-mode ace-isearch))))

;; gdb
;;(setq gdb-many-windows t)
;; ((setq gdb-many-windows nil)

(defun set-gdb-layout(&optional c-buffer)
  (if (not c-buffer)
      (setq c-buffer (window-buffer (selected-window)))) ;; save current buffer

  ;; from http://stackoverflow.com/q/39762833/846686
  (set-window-dedicated-p (selected-window) nil) ;; unset dedicate state if needed
  (switch-to-buffer gud-comint-buffer)
  (delete-other-windows) ;; clean all

  (let* (
         (w-gdb (selected-window)) ;; left top
         (w-stack (split-window w-gdb (floor(* 0.85 (window-body-height))) 'below)) ;; left bottom
         (w-source (split-window w-gdb nil 'right)) ;; right top
         (w-io (split-window w-gdb (floor(* 0.5 (window-body-height))) 'below)) ;; left middle
         (w-breakpoints (split-window w-stack nil 'right)) ;; right bottom
         )
         ;; (w-source (selected-window)) ;; left top
         ;; (w-gdb (split-window w-source nil 'right)) ;; right bottom
         ;; (w-locals (split-window w-gdb nil 'above)) ;; right middle bottom
         ;; (w-stack (split-window w-locals nil 'above)) ;; right middle top
         ;; (w-breakpoints (split-window w-stack nil 'above)) ;; right top
         ;; (w-io (split-window w-source (floor(* 0.7 (window-body-height)))
         ;;                     'below)) ;; left bottom
         ;; )
    (set-window-buffer w-io (gdb-get-buffer-create 'gdb-inferior-io))
    (set-window-dedicated-p w-io t)
    (set-window-buffer w-breakpoints (gdb-get-buffer-create 'gdb-breakpoints-buffer))
    (set-window-dedicated-p w-breakpoints t)
    ;; (set-window-buffer w-locals (gdb-get-buffer-create 'gdb-locals-buffer))
    ;; (set-window-dedicated-p w-locals t)
    (set-window-buffer w-stack (gdb-get-buffer-create 'gdb-stack-buffer))
    (set-window-dedicated-p w-stack t)

    (set-window-buffer w-gdb gud-comint-buffer)

    (select-window w-source)
    (set-window-buffer w-source c-buffer)
    ))

(defadvice gdb (around args activate)
  "Change the way to gdb works."
  (setq global-config-editing (current-window-configuration)) ;; to restore: (set-window-configuration c-editing)
  (let (
        (c-buffer (window-buffer (selected-window))) ;; save current buffer
        )
    ad-do-it
    (set-gdb-layout c-buffer))
  )

(defadvice gdb-reset (around args activate)
  "Change the way to gdb exit."
  ad-do-it
  (set-window-configuration global-config-editing))

(add-hook 'gdb-mode-hook '(lambda () (gud-tooltip-mode t)))


;; -----------------------------------------------------------------
;; @ key bindings

;; exchange DEL and BS
;(global-set-key "￥C-h" 'delete-backward-char)
(normal-erase-is-backspace-mode 0)

;;; set key [お好きなように]
(global-set-key "\C-x\j" 'goto-line)
;(global-set-key "\M-/" 'auto-fill-mode)
(global-set-key "\M-r" 'redraw-display)
(global-set-key "\C-x\C-[" 'repeat-complex-command)
(global-set-key "\C-x\C-r" 'replace-string)
(global-set-key "\C-c\C-c" 'comment-or-uncomment-region)
(global-set-key "\C-x\C-l" 'revert-buffer)
(global-set-key "\C-c\t" 'toggle-truncate-lines)
(global-set-key "\C-t" 'other-window)
(global-set-key "\C-c\C-d" 'gdb)
(global-set-key "\C-c\M-h" 'help-command)
(global-set-key "\C-c\q" 'quickrun)


;; window移動
(setq windmove-wrap-around t)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)


;; -----------------------------------------------------------------
;; @ C/C++

(require 'cc-mode)

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

;; ヘッダファイル(.h)をc++モードで開く
(setq auto-mode-alist
      (append '(("\\.h$" . c++-mode))
              auto-mode-alist))

;; C++11モードのシンタックスハイライトを有効
(require 'modern-cpp-font-lock)
(modern-c++-font-lock-global-mode t)

;;
;; for text-mode
;;
;; text-mode では、自動的に auto-fill-mode にする
;(setq text-mode-hook
;      '(lambda ()
;	 (auto-fill-mode 1)))
;; auto-fill-mode では、各行を 70 文字以内に詰める
(set-default 'fill-column 60)


;; ----------------------------------------------------------------
;; for LLVM
;; Add a cc-mode style for editing LLVM C and C++ code
(c-add-style "llvm.org"
             '("gnu"
	       (fill-column . 80)
	       (c++-indent-level . 2)
	       (c-basic-offset . 2)
	       (indent-tabs-mode . nil)
	       (c-offsets-alist . ((arglist-intro . ++)
				   (innamespace . 0)
				   (member-init-intro . ++)))))

;; -----------------------------------------------------------------
;; @elscreen

(require 'elscreen)

(elscreen-set-prefix-key "\C-z")

;;; [X]を表示しない
(setq elscreen-tab-display-kill-screen nil)
;;; [<->]を表示しない
(setq elscreen-tab-display-control nil)

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

(require 'elscreen-color-theme)

(elscreen-start)


;; ;; smooth-scroll
;; (require 'smooth-scroll)
;; (smooth-scroll-mode t)


;; undo-tree
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)


;; which-key
;; (which-key-setup-side-window-bottom)  ;; ミニバッファに表示
(which-key-mode 1)


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
(global-set-key (kbd "C-c l s") 'highlight-symbol-at-point)
(global-set-key (kbd "C-c l r") 'highlight-symbol-query-replace)
(global-set-key (kbd "C-c l d") 'highlight-symbol-remove-all)


;; powerline
(require 'powerline)
(require 'monokai-theme)

(set-face-attribute 'powerline-active0 nil
                    :foreground monokai-violet
                    :background monokai-gray
                    :box nil)

(set-face-attribute 'powerline-active2 nil
                    :foreground monokai-foreground
                    :background monokai-red
                    :box nil
                    :bold t)

(set-face-attribute 'powerline-inactive2 nil
                    :bold t)


(defun powerline-my-theme ()
  "Setup the my mode-line."
  (interactive)
  (setq powerline-current-separator 'utf-8)
  (setq-default mode-line-format
                '("%e"
                  (:eval
                   (let* ((active (powerline-selected-window-active))
                          (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
                          (mode-line (if active 'mode-line 'mode-line-inactive))
                          (face0 (if active 'powerline-active0 'powerline-inactive1))
                          (face1 (if active 'powerline-active2 'powerline-inactive2))
                          (face2 (if active 'powerline-active1 'powerline-inactive1))
                          (separator-left (intern (format "powerline-%s-%s"
                                                          (powerline-current-separator)
                                                          (car powerline-default-separator-dir))))
                          (separator-right (intern (format "powerline-%s-%s"
                                                           (powerline-current-separator)
                                                           (cdr powerline-default-separator-dir))))
                          (lhs (list (powerline-major-mode face0 'l)
                                     (powerline-raw " " face0)
                                     (funcall separator-left face0 face1)
                                     (powerline-buffer-id face1 'l)
                                     (powerline-raw " " face1)
                                     ;; (when (and (boundp 'which-func-mode) which-func-mode)
                                     ;;   (powerline-raw which-func-format face1 'l))
                                     (funcall separator-left face1 face2)
                                     (powerline-vc face2 'l)
                                     ))
                          (rhs (list (when powerline-display-mule-info
                                       (powerline-raw mode-line-mule-info face2 'r))
                                     (funcall separator-right face2 face1)
                                     (powerline-raw " " face1 'r)
                                     (unless window-system
                                       (powerline-raw (char-to-string #xe0a1) face1 'r))
                                     (powerline-raw "%5l" face1 'r)
                                     (powerline-raw ":" face1 'r)
                                     (powerline-raw "%3c" face1 'r)
                                     (funcall separator-right face1 face0)
                                     (powerline-raw " " face0 'r)
                                     (powerline-raw "%6p" face0 'r)
                                     (powerline-raw " " face0 'r)
                                     )))
                     (concat (powerline-render lhs)
                             (powerline-fill face2 (powerline-width rhs))
                             (powerline-render rhs)))))))

(powerline-my-theme)


(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)


;; easy-kill
(require 'easy-kill)
(global-set-key (kbd "M-w") 'easy-kill)


;; magit
(require 'magit)
(require 'magit-lfs)
(global-set-key (kbd "C-x g") 'magit-status)
 ;; (custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;; '(magit-diff-added ((t (:background "black" :foreground "green"))))
 ;; '(magit-diff-added-highlight ((t (:background "white" :foreground "green"))))
 ;; '(magit-diff-removed ((t (:background "black" :foreground "blue"))))
 ;; '(magit-diff-removed-hightlight ((t (:background "white" :foreground "blue"))))
 ;; '(magit-hash ((t (:foreground "red")))))
(setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)


;; helm
(require 'helm)
(require 'helm-config)
(require 'helm-ag)
(require 'helm-swoop)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(setq helm-ag-base-command "ag --nocolor --nogroup --ignore-case")
(setq helm-ag-thing-at-point 'symbol)
(global-set-key (kbd "C-c a") 'helm-ag)
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

;; '.' '..' を除外する
(advice-add 'helm-ff-filter-candidate-one-by-one
        :around (lambda (fcn file)
                  (unless (string-match "\\(?:/\\|\\`\\)\\.\\{1,2\\}\\'" file)
                    (funcall fcn file))))

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

(add-hook 'c-mode-common-hook 'irony-mode)

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
(with-eval-after-load 'company
  (setq company-auto-expand t) ;; 1個目を自動的に補完
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq completion-ignore-case t)
  (setq company-dabbrev-downcase nil)
  (global-set-key (kbd "C-M-i") 'company-complete)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  ;;(define-key c-mode-map [<tab>] 'company-complete)
  ;;(define-key c++-mode-map [<tab>] 'company-complete)


  (defun company--insert-candidate2 (candidate)
    (when (> (length candidate) 0)
      (setq candidate (substring-no-properties candidate))
      (if (eq (company-call-backend 'ignore-case) 'keep-prefix)
          (insert (company-strip-prefix candidate))
        (if (equal company-prefix candidate)
            (company-select-next)
          (delete-region (- (point) (length company-prefix)) (point))
          (insert candidate))
        )))

  (defun company-complete-common2 ()
    (interactive)
    (when (company-manual-begin)
      (if (and (not (cdr company-candidates))
               (equal company-common (car company-candidates)))
          (company-complete-selection)
        (company--insert-candidate2 company-common))))

  (define-key company-active-map [tab] 'company-complete-common2)
  (define-key company-active-map [backtab] 'company-select-previous) ; おまけ

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

  (add-to-list `company-backends '(company-irony-c-headers company-irony));; company-yasnippet))
  (add-hook 'c++-mode-hook 'company-mode)
  ;; (global-company-mode 1)
)


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

(eval-after-load "flycheck"
  '(progn
     (when (locate-library "flycheck-irony")
       (flycheck-irony-setup))))


;; ;; dump-jump
;; (require 'dumb-jump)
;; (setq dumb-jump-mode t)
;; (define-key global-map (kbd "C-c j") 'dumb-jump-go)
;; (define-key global-map (kbd "C-c o") 'dumb-jump-go-other-window)
;; (define-key global-map (kbd "C-c b") 'dumb-jump-back)


;; gtags
;; ;;; counsel-gtags
;; (require 'counsel-gtags)
;; (setq counsel-gtags-auto-update t)
;;   (add-hook 'counsel-gtags-mode-hook
;;             '(lambda ()
;;                (local-set-key (kbd "M-.") 'counsel-gtags-dwim)
;;                (local-set-key (kbd "M-r") 'counsel-gtags-find-rtag)
;;                (local-set-key (kbd "M-s") 'counsel-gtags-find-symbol)
;;                (local-set-key (kbd "M-,") 'counsel-gtags-pop-stack)))
;; (add-hook 'c-mode-hook 'counsel-gtags-mode)
;; (add-hook 'c++-mode-hook 'counsel-gtags-mode)

;;; helm-gtags
(require 'helm-gtags)
(setq helm-gtags-auto-update t)
  (add-hook 'helm-gtags-mode-hook
            '(lambda ()
               (local-set-key (kbd "M-.") 'helm-gtags-dwim)
               (local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
               (local-set-key (kbd "M-s") 'helm-gtags-find-symbol)
               (local-set-key (kbd "M-,") 'helm-gtags-pop-stack)))
(add-hook 'c++-mode-hook 'helm-gtags-mode)

;; rtags
;; (add-to-list 'load-path "/usr/local/share/emacs/site-lisp/rtags/")
;; (require 'rtags)
;; (require 'company-rtags)

;; (setq rtags-completions-enabled t)
;; (setq rtags-autostart-diagnostics t)
;; (rtags-enable-standard-keybindings)

;; (require 'helm-rtags)
;; (setq rtags-use-helm t)

;; (when (require 'rtags nil 'noerror)
;;   (add-hook 'c-mode-common-hook
;;             (lambda ()
;;               ;; (when (rtags-is-indexed)
;;                 (local-set-key (kbd "M-.") 'rtags-find-symbol-at-point)
;;                 (local-set-key (kbd "M-r") 'rtags-find-references)
;;                 (local-set-key (kbd "M-s") 'rtags-find-symbol)
;;                 (local-set-key (kbd "M-,") 'rtags-location-stack-back))))


;; ;; ivy
;; (require 'ivy)
;; (ivy-mode 1)
;; (setq ivy-use-virtual-buffers t)
;; (setq enable-recursive-minibuffers t)
;; (setq ivy-height 30) ;; minibufferのサイズを拡大！（重要）
;; (setq ivy-extra-directories nil)
;; (setq ivy-re-builders-alist
;;       '((t . ivy--regex-plus)))

;; ;; counsel
;; (global-set-key (kbd "M-x") 'counsel-M-x)
;; (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;; (global-set-key (kbd "C-c g") 'counsel-git-grep)
;; (defvar counsel-find-file-ignore-regexp (regexp-opt '("./" "../")))


;; swiper
(global-set-key "\C-s" 'swiper)
(defvar swiper-include-line-number-in-search t) ;; line-numberでも検索可能

;; migemo + swiper
;(require 'avy-migemo)
;(avy-migemo-mode 1)
;(require 'avy-migemo-e.g.swiper)

(require 'cmake-ide)
(cmake-ide-setup)
(global-set-key "\C-c\m" 'cmake-ide-compile)
(setq cmake-ide-header-search-other-file nil)
(setq cmake-ide-header-search-first-including nil)
;; (setq cmake-ide-rdm-executable "/usr/local/bin/rdm")
;; (setq cmake-ide-rc-executable "/usrlocal/bin/rc")

;; disaster
(require 'disaster)
(define-key c-mode-base-map (kbd "C-c d") 'disaster)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
