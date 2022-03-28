# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
cc-1.0.73
libc-0.2.119
hidapi-1.2.5
pkg-config-0.3.24
xml-rs-0.8.0
"

# Refs:
# * https://devmanual.gentoo.org/eclass-reference/cargo.eclass  # Rust stuff
# * https://devmanual.gentoo.org/eclass-reference/udev.eclass  # udev rules
inherit cargo udev

DESCRIPTION="FGFS Saitek Switch Panel Driver for Windows and Linux"
HOMEPAGE="https://github.com/daibach142/SaitekSwitch"

SRC_URI="https://github.com/daibach142/SaitekSwitch/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris)"

# NOTE: "QA_FLAGS_IGNORED"
# NOTE: This should contain a list of file paths, relative to the image
# NOTE: directory, of files that do not contain .GCC.command.line
# NOTE: sections or contain .hash sections. The paths may contain
# NOTE: regular expressions with escape-quoted special characters.
# NOTE: This variable is intended to be used on files of binary packages
# NOTE: which ignore CFLAGS, CXXFLAGS, FFLAGS, FCFLAGS, and LDFLAGS
# NOTE: variables.
# Ref: https://devmanual.gentoo.org/eclass-reference/ebuild
QA_FLAGS_IGNORED="usr/bin/saitekswitch"  # FIXME: Is this needed?

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RUST_SRC_DIR=code/saitekswitch/
# NOTE: "S"
# NOTE: Path to the temporary build directory, used by src_compile and
# NOTE: src_install. Default: "${WORKDIR}/${P}". Ebuilds should not
# provide a value for this variable if it is the same as the default
# value.
# Ref: https://devmanual.gentoo.org/ebuild-writing/variables
S="${WORKDIR}/${P}/${RUST_SRC_DIR}"  # default: S="${WORKDIR}/${P}"

src_install() {
	cargo_src_install

	insinto /usr/share/flightgear/Nasal/
	doins ../../saitekswitch.nas

	insinto /usr/share/flightgear/Protocol/
	doins ../../saitekswitch.xml

	insinto /usr/share/X11/xorg.conf.d/
	newins ../../55-saitekpanels.conf 55-saitek-switch-panel.conf

	udev_newrules ../../55-saitek.rules 55-saitek-switch-panel.rules
	udev_reload
}
