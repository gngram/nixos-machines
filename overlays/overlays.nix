# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# This overlay patches packages in nixpkgs, and adds in some of the ghaf's
# packages.
#
#
final: prev: {
  cosmic-applets = import ./cosmic/cosmic-applets { inherit prev; };
  cosmic-greeter = import ./cosmic/cosmic-greeter { inherit prev; };
  cosmic-settings = import ./cosmic/cosmic-settings { inherit prev; };
  cosmic-comp = import ./cosmic/cosmic-comp { inherit prev; };
  cosmic-osd = import ./cosmic/cosmic-osd { inherit prev; };
  xdg-desktop-portal-cosmic = import ./cosmic/xdg-desktop-portal-cosmic { inherit prev; };
}
