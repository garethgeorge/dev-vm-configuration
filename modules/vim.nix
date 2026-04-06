{ pkgs, ... }:
let
  customVim = pkgs.vim-full.customize {
    name = "vim";
    vimrcConfig.packages.default = with pkgs.vimPlugins; {
      start = [
        # Syntax highlighting for many languages
        vim-polyglot

        # LSP client
        vim-lsp

        # Auto-detect installed language servers
        vim-lsp-settings

        # Async autocompletion framework
        asyncomplete-vim
        asyncomplete-lsp-vim

        # Quality of life
        vim-sensible
        vim-surround
        vim-commentary
      ];
    };
    vimrcConfig.customRC = ''
      " ─── General ──────────────────────────────────────────────────────────
      syntax on
      filetype plugin indent on
      set number
      set relativenumber
      set mouse=a
      set hidden
      set signcolumn=yes
      set updatetime=300
      set shortmess+=c
      set completeopt=menuone,noinsert,noselect
      set backspace=indent,eol,start

      " Indentation defaults (2 spaces)
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent

      " Search
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase

      " ─── LSP Server Registration ─────────────────────────────────────────
      " These use the language servers installed via Nix in packages.nix

      if executable('gopls')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'gopls',
          \ cmd: {server_info->['gopls']},
          \ allowlist: ['go', 'gomod', 'gowork'],
          \ })
      endif

      if executable('pyright-langserver')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'pyright',
          \ cmd: {server_info->['pyright-langserver', '--stdio']},
          \ allowlist: ['python'],
          \ })
      endif

      if executable('typescript-language-server')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'typescript-language-server',
          \ cmd: {server_info->['typescript-language-server', '--stdio']},
          \ allowlist: ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
          \ })
      endif

      if executable('rust-analyzer')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'rust-analyzer',
          \ cmd: {server_info->['rust-analyzer']},
          \ allowlist: ['rust'],
          \ })
      endif

      if executable('nil')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'nil',
          \ cmd: {server_info->['nil']},
          \ allowlist: ['nix'],
          \ })
      endif

      if executable('clangd')
        au User lsp_setup call lsp#register_server(#{
          \ name: 'clangd',
          \ cmd: {server_info->['clangd', '--background-index']},
          \ allowlist: ['c', 'cpp', 'objc', 'objcpp'],
          \ })
      endif

      " ─── LSP Keybindings ─────────────────────────────────────────────────
      function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> gt <plug>(lsp-type-definition)
        nmap <buffer> K  <plug>(lsp-hover)
        nmap <buffer> <leader>rn <plug>(lsp-rename)
        nmap <buffer> <leader>ca <plug>(lsp-code-action)
        nmap <buffer> [d <plug>(lsp-previous-diagnostic)
        nmap <buffer> ]d <plug>(lsp-next-diagnostic)
      endfunction

      augroup lsp_install
        au!
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
      augroup END

      " ─── Diagnostics ─────────────────────────────────────────────────────
      let g:lsp_diagnostics_echo_cursor = 1
      let g:lsp_diagnostics_float_cursor = 1
      let g:lsp_diagnostics_signs_enabled = 1
    '';
  };
in
{
  environment.systemPackages = [ customVim ];
}
