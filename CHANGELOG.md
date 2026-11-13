# Changelog

## 2.1.0

- Requires Flutter 3.47 or newer and Dart 3.13 or newer, with `material_ui`
  1.4.0 or newer. Apps on Flutter 3.44 to 3.46 keep getting 2.0.0.

## 2.0.0

### Breaking changes

- The widgets are built with [material_ui](https://pub.dev/packages/material_ui)
  instead of `package:flutter/material.dart`, which is deprecated since
  Flutter 3.47. `InternationalPhoneNumberInput.decoration` and
  `SelectorConfig.searchDecoration` take the `InputDecoration` of
  `material_ui`, and the input needs a `MaterialApp` and `Scaffold` from
  `material_ui` to find its theme and `Material`.

  To migrate, run `dart fix --apply --code=migrate_design_widgets` in your
  app. It adds `material_ui` and changes the imports of
  `package:flutter/material.dart` to `package:material_ui/material_ui.dart`.
  Apps that keep `package:flutter/material.dart` can stay on 1.1.0.

- Requires Flutter 3.44 or newer and Dart 3.12 or newer, the minimum of
  `material_ui` 1.2.0. Version 1.1.0 required Dart 3.13 (Flutter 3.47).

## 1.1.0

### Features

- Ascension Island (`AC`, `+247`) and Tristan da Cunha (`TA`, `+290`), with
  names in all 22 languages and their flags. There are now 251 countries and
  territories.
- Numbers of territories that libphonenumber has no data for, namely
  Antarctica, Bouvet Island, the French Southern Territories, Heard Island
  and McDonald Islands, Pitcairn and South Georgia, are validated and
  formatted by the numbering plan of their dial code, e.g. Norway for Bouvet
  Island. Before, they were never valid. A pasted number keeps the selected
  territory.
- Updated `dlibphonenumber` to 1.1.76, with the latest numbering data for
  regions such as Australia, Benin, China, Germany, India and Romania.

### Fixes

- Vatican City uses `+39` instead of `+379`.
- Heard Island and McDonald Islands use `+672` instead of `+0`.
- Saint Helena is named "Saint Helena", now that Ascension Island and Tristan
  da Cunha are listed on their own, and has its own flag instead of the
  British one.

## 1.0.0

First release of `smart_phone_input`.

It started as a fork of [intl_phone_number_input](https://pub.dev/packages/intl_phone_number_input)
0.7.5 and was rewritten with a new API, so it is not a drop-in replacement.
See [Migrating from intl_phone_number_input](README.md#migrating-from-intl_phone_number_input).

### Features

- `InternationalPhoneNumberInput`, a form field with a country selector as a
  dropdown, bottom sheet or dialog, using the parameter names of
  `TextFormField`.
- `PhoneNumber`, an immutable value with the country, the digits as typed, the
  E.164 form, validity, type and formatting, plus `PhoneNumber.tryParse`.
- Formatting as you type in the national style of each country, with or
  without the national prefix, e.g. `0599 123 456`.
- Typed or pasted international numbers, such as `+966 50 123 4567` or
  `00966…`, switch to their country.
- Arabic-Indic and Persian digits are converted as they are typed.
- The country search ignores case, accents, Arabic letter variants,
  diacritics and the article ال, and ranks the best matches first.
- Country names and texts follow the locale. Texts are built in for 22
  languages, and apps can override them or register more.
- The first country comes from the device's locale when there is no initial
  value. Favorite countries can be listed first.
- `Countries` lookups by ISO code and dial code, and `PhoneInputKeys` for
  widget tests.
- 249 countries and territories, including Sint Maarten and Western Sahara.
- Depends only on Flutter and `dlibphonenumber`.

### Fixes compared to intl_phone_number_input 0.7.5

- Autovalidation no longer rebuilds the field on every frame.
- The selected country is no longer reset when the parent rebuilds.
- `onSaved` reports the same number as `onChanged`.
- Formatting no longer flickers or loses digits while typing fast, and
  backspace over a separator works.
- `maxDigits` counts digits, not spaces and dashes.
- Malformed initial values and unknown country codes no longer throw.
- The selector stays level with the text when an error appears.
- Dial codes shared by several countries, such as `+1`, return the main
  country.
