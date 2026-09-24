#!/usr/bin/env just --justfile

set shell := ["zsh", "-uc"]
set script-interpreter := ["zsh", "-u"]

# ------ Variables ------

required_deps := "ttfautohint nvm npm"
plan := "iosevka-aw-term"

# ------ Helper Recipes ------

[private]
@default:
  just --justfile {{ justfile() }} --list --unsorted

[private]
[shell]
@check-deps:
  for dep in {{ required_deps }}; do command -v "$dep" >/dev/null || { echo "$dep is required"; exit 1; }; done

# Print supported build modes.
[private]
@build-echo:
  echo 'Usage: just build <mode>'
  echo
  echo 'Supported build modes:'
  echo '  contents          Everything (TTF + webfont, hinted + unhinted)'
  echo '  all               Alias for contents'
  echo '  ttf               TTF only'
  echo '  ttf-unhinted      Unhinted TTF only'
  echo '  webfont           Web fonts only (CSS + WOFF2)'
  echo '  webfont-unhinted  Unhinted web fonts only (CSS + WOFF2)'
  echo '  woff2             WOFF2 only'
  echo '  woff2-unhinted    Unhinted WOFF2 only'



[shell]
bootstrap: check-deps
  ~/.nvm/nvm.sh use && npm install

# Build the selected Iosevka output mode.
@build mode="":
  case "{{mode}}" in contents|ttf|ttf-unhinted|webfont|webfont-unhinted|woff2|woff2-unhinted) npm run build -- "{{mode}}::{{plan}}" ;; all) npm run build -- "contents::{{plan}}" ;; *) just --justfile {{ justfile() }} build-echo ;; esac

# https://github.com/be5invis/Iosevka/blob/main/doc/custom-build.md

# TTC Building
#
# It is possible to create a customized TTC build by using the following method:
#
# Add a collect plan into private-build-plans.toml, with a from field containing all the TTF groups it needs:
# [collectPlans.IosevkaCustom]
# from = ["IosevkaCustom1", "IosevkaCustom2"]
# Run build with the following command:
# npm run build -- ttc::IosevkaCustom: Create TTCs from collection IosevkaCustom; The file will be saved into dist/.ttc.
# npm run build -- super-ttc::IosevkaCustom: Create a single-file TTC from collection IosevkaCustom; The file will be saved into dist/.super-ttc.
# Single-Group TTCs (SGr)
#
# When your collection contains multiple groups (e.g. different spacing variants), you can also build separate TTCs for each group individually:
#
# npm run build -- sgr-ttc::IosevkaCustom: Create individual TTCs for each group in collection IosevkaCustom; Files will be saved into dist/.ttc/SGr-<group>/.
# npm run build -- sgr-super-ttc::IosevkaCustom: Create individual single-file TTCs for each group in collection IosevkaCustom; Files will be saved into dist/.super-ttc/.
# To build both bundled and single-group TTCs in one command:
#
# npm run build -- all-ttc::IosevkaCustom: Create both bundled and separate SGr TTCs.
# npm run build -- all-super-ttc::IosevkaCustom: Create both bundled and separate SGr Super TTCs.
# Note: SGR commands require the collection to have more than one group in the from array, since they'd otherwise be equivalent to the regular bundled TTCs.
#
# Baking other OpenType features
#
# There are tools tha could be used to bake other OpenType that are not configurable with TOML files (like baking localized forms). The tools include:
#
# https://mutsuntsai.github.io/fontfreeze/
# https://github.com/twardoch/fonttools-opentype-feature-freezer
# These tools could be used in post-processing fonts. Please refer their documents for instructions.
