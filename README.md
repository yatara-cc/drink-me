# Drink Me

4% ergo macropad

> However, this bottle was not marked ‘poison,’ so Alice ventured to taste it... ‘What a curious feeling!’ said Alice; ‘I must be shutting up like a telescope.’


## Getting started

### Hardware

-   The base and case are “snap-fit”; you can open and close them by pushing or pulling vertically with care.
-   Make sure switch pins are completely straight before inserting them into the hotswap sockets, otherwise the pins may miss the holes and cause damage.
-   It is recommended to remove the case from the base/thumbrest and support the hotswap sockets with your finger or thumb while inserting switches.


### Firmware

Drink Me ships with [VIA](https://caniusevia.com/) firmware preinstalled. To customise your keymap, install and run the [latest version](https://github.com/the-via/releases) on your computer; when you plug in your Drink Me it will be recognised and you can edit the keymap in realtime.

You can also use the online [QMK Configurator](https://config.qmk.fm/#/yatara/drink_me/LAYOUT) to create a custom firmware for your Drink Me. Alternatively download the [QMK](https://github.com/qmk/qmk_firmware) source where you will find [example code and keymaps for Drink Me](https://github.com/qmk/qmk_firmware/tree/master/keyboards/yatara/drink_me) that can be modified to use any of QMK's [extensive features](https://docs.qmk.fm/#/).


### Help & Support

Buyers can access support by sending a message to the email address on the PayPal invoice.


## Modification and Development

This project is released under the GNU General Public License v3. You are encouraged to modify its content to meet your own requirements provided you respect the terms of the licence.

This repository includes automated scripts for various tasks. However, the PCB and geometry files can be modified in their respective software without recourse to these scripts.


### Dependencies for automated scripts

-   POSIX OS (eg. Linux or OSX)
-   Bash
-   Gnu Make
-   Python >= 3.7
-   Meshlab

Python modules:

-   GeoTK
-   Kiplot

To install Python modules run:

```
make install-python
```


### PCB

#### Dependencies

-   [KiCad](https://kicad-pcb.org/download/) >= 5.1

Components from the following libraries were used, but these are not required in order to use the PCB files.

-   [Yatara KiCad library](https://github.com/yatara-cc/kicad)
-   [TMK symbol library](https://github.com/tmk/kicad_lib_tmk)
-   [TMK footprint library](https://github.com/tmk/keyboard_parts.pretty )
-   [SnapEDA GCT_USB4105_REVA libraries](https://www.snapeda.com/parts/USB4105-GF-A/GCT/view-part/)


#### Export Gerber files for manufacture

```
make gerber
ll gerber
```


### Printed Parts

#### Dependencies

-   OpenSCAD


#### Export STL files for manufacture

```
make stl
ll stl
```


## References

-   [Photo Gallery](https://imgur.com/a/9XkbmKo) - 2020-01-24
-   [Geekhack Interest Check](https://geekhack.org/index.php?topic=104449.0) - 2020-01-29
-   [Geekhack Group Buy](https://geekhack.org/index.php?topic=104974.0) - 2020-03-04
-   [Reddit r/MechanicalKeyboards first look](https://www.reddit.com/r/MechanicalKeyboards/comments/eswx1z/drink_me/) - 2020-01-23
-   [Reddit r/MechanicalKeyboards Interest Check & Giveaway](https://www.reddit.com/r/MechanicalKeyboards/comments/evu429/ic_drink_me_4_ergo_interest_check_giveaway/) - 2020-02-19
-   [Reddit r/MechanicalKeyboard Group Buy announcement](https://www.reddit.com/r/MechanicalKeyboards/comments/f9hhyl/drink_me_group_buy_starts_march_5th_2020/) - 2020-03-05
-   [Reddit r/MechanicalKeyboard Group Buy](https://www.reddit.com/r/MechanicalKeyboards/comments/fe147m/drink_me_group_buy_is_live/) - 2020-03-05
-   [Reddit r/mechmarket Group Buy](https://www.reddit.com/r/mechmarket/comments/fe16nw/gb_drink_me_4_ergo_group_buy_is_live/) - 2020-03-05
-   [QMK page](https://github.com/qmk/qmk_firmware/tree/master/keyboards/yatara/drink_me)
-   [QMK Pull Request](https://github.com/qmk/qmk_firmware/pull/8039) - 2020-01-30
-   [QMK Configurator Pull Request](https://github.com/qmk/qmk_configurator/pull/648) - 2020-01-30
-   [VIA Pull Request](https://github.com/the-via/keyboards/pull/37) - 2020-01-31


> ‘It was much pleasanter at home,’ thought poor Alice, ‘when one wasn’t always growing larger and smaller... I almost wish I hadn’t gone down that rabbit-hole
