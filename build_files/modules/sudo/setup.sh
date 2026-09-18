#!/usr/bin/bash
set -eoux pipefail
# Asteriscos no prompt de senha do sudo. A receita so faz `sudo tee` de
# /etc/sudoers.d/enable-pwfeedback, e como root no build o sudo nao pede senha.
ujust password-feedback on
