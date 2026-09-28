#!/bin/bash
# Keep Herdr's UI colors in sync with the active Omarchy theme.
#
# tmux can `source-file` a generated snippet; Herdr has no include mechanism, so
# this hook instead renders the whole effective config: the repo's base
# config.toml plus a [theme.custom] block built from the active colors.toml.
# The result is written to ~/.config/herdr/config.toml (replacing the plain
# symlink used on macOS) and the running server is reloaded.
#
# Installed as an Omarchy `theme-set` (and `post-boot`) hook, so every
# `omarchy theme set` and every login refreshes it.

set -euo pipefail

OMARCHY_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current"
COLORS_FILE="$OMARCHY_STATE/theme/colors.toml"
THEME_NAME="$(cat "$OMARCHY_STATE/theme.name" 2>/dev/null || echo unknown)"

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"
BASE_CONFIG="$SCRIPT_DIR/../config.toml"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml"

[[ -f $COLORS_FILE ]] || exit 0
[[ -f $BASE_CONFIG ]] || exit 0

# Resolve a colors.toml key, optionally falling back to a second key.
color() {
  local value
  value="$(omarchy-theme-color --file "$COLORS_FILE" "$1" 2>/dev/null || true)"
  if [[ -z $value && -n ${2:-} ]]; then
    value="$(omarchy-theme-color --file "$COLORS_FILE" "$2" 2>/dev/null || true)"
  fi
  printf '%s' "$value"
}

is_color() { [[ $1 =~ ^#[0-9A-Fa-f]{6}$ ]]; }

# Assign only valid colors, so a malformed theme degrades to the base theme
# instead of writing invalid TOML.
set_color() {
  local name="$1" value="$2"
  if is_color "$value"; then
    printf -v "$name" '%s' "$value"
  else
    printf -v "$name" '%s' ""
  fi
}

set_color bg         "$(color background color0)"
set_color dark_bg    "$(color dark_background dark_bg)"
set_color darker_bg  "$(color darker_background darker_bg)"
set_color lighter_bg "$(color lighter_background lighter_bg)"
set_color fg         "$(color foreground fg)"
set_color selection  "$(color selection_background selection)"
set_color accent     "$(color accent color6)"
set_color red        "$(color red color1)"
set_color green      "$(color green color2)"
set_color yellow     "$(color yellow color3)"
set_color blue       "$(color blue color4)"
set_color magenta    "$(color magenta color5)"
set_color cyan       "$(color cyan color6)"
set_color orange     "$(color orange bright_yellow)"

# Omarchy's own TUI themes (pi.json, claude.json, t3code.json, shell.toml)
# derive secondary text and the active sidebar row with the template engine's
# `mix` helper, so every app keeps the same contrast. Herdr's `muted` slot is
# the bright-black ANSI colour, which on dark themes such as amberbyte
# (#2b1818 on a #1b1112 background) reads as invisible text, so derive the
# same shades the rest of the desktop uses instead of trusting `muted`.
mix() {
  local h1=${1#'#'} h2=${2#'#'} pct=$3
  local r1=$((16#${h1:0:2})) g1=$((16#${h1:2:2})) b1=$((16#${h1:4:2}))
  local r2=$((16#${h2:0:2})) g2=$((16#${h2:2:2})) b2=$((16#${h2:4:2}))
  printf '#%02x%02x%02x' \
    $(((r1 * (100 - pct) + r2 * pct + 50) / 100)) \
    $(((g1 * (100 - pct) + g2 * pct + 50) / 100)) \
    $(((b1 * (100 - pct) + b2 * pct + 50) / 100))
}

dim_text=""
mid_text=""
muted_text=""
active_row=""
if is_color "$fg" && is_color "$bg"; then
  dim_text="$(mix "$fg" "$bg" 52)"
  mid_text="$(mix "$fg" "$bg" 45)"
  muted_text="$(mix "$fg" "$bg" 34)"
fi
if is_color "$bg" && is_color "$accent"; then
  active_row="$(mix "$bg" "$accent" 18)"
fi

# Emit one token, skipping it when its color could not be resolved.
token() {
  local key="$1" value="$2"
  if [[ -n $value ]]; then
    printf '%s = "%s"\n' "$key" "$value"
  fi
}

theme_custom="$(
  {
    token sidebar_bg    "$bg"
    token panel_bg      "$bg"
    token active_row_bg "$active_row"
    token selection_bg  "$selection"
    token surface_dim   "$darker_bg"
    token surface0      "$dark_bg"
    token surface1      "$lighter_bg"
    token overlay0      "$dim_text"
    token overlay1      "$mid_text"
    token text          "$fg"
    token subtext0      "$muted_text"
    token accent        "$accent"
    token red           "$red"
    token green         "$green"
    token yellow        "$yellow"
    token blue          "$blue"
    token teal          "$cyan"
    token mauve         "$magenta"
    token peach         "$orange"
  }
)"

# Drop any [theme.custom] the base file may carry, so we never emit it twice.
strip_theme_custom() {
  awk '
    /^\[theme\.custom[.\]]/ { skip = 1; next }
    skip && /^\[/ { skip = 0 }
    skip { next }
    { print }
  ' "$1"
}

mkdir -p -- "$(dirname -- "$DEST")"
tmp="$(mktemp)"
trap 'rm -f -- "$tmp"' EXIT

strip_theme_custom "$BASE_CONFIG" >"$tmp"
{
  printf '\n# Generated from Omarchy theme "%s" by omarchy/herdr-theme.sh.\n' "$THEME_NAME"
  printf '# Do not edit by hand - rewritten on every `omarchy theme set`.\n\n'
  printf '[theme.custom]\n'
  printf '%s' "$theme_custom"
} >>"$tmp"

chmod 0644 "$tmp"
mv -f -- "$tmp" "$DEST"
trap - EXIT

# Apply to the running server, if any.
if herdr status server >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 || true
fi
