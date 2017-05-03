From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 May 2017 06:31:34 -0400
Subject: v2_02_171 annotated tag has been created
Message-ID: <201705031031.v43AVYL1017696@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94b2eeae57643f32c180330b910046a56177c4e6
Commit:        94b2eeae57643f32c180330b910046a56177c4e6
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-05-03 10:25 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-05-03 10:25 +0000

annotated tag: v2_02_171 has been created
	    at 94b2eeae57643f32c180330b910046a56177c4e6 (tag)
       tagging fb4bf1f4eae9ce49f9e0d606240867320dcb8dac (commit)
      replaces v2_02_170

Version 2.02.171

Another development checkpoint release.  We have stopped adding
features as we work towards the next stable release, but please still
only use this release for testing purposes while we continue to
find and fix bugs.

96 files changed, 1120 insertions(+), 604 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlkJsDsACgkQIoGRwVZ+LBd0HQCffqh3CxbNW29k9Y/5iTFCPIqR
pvgAoJBZj7QxWIfILJC69UhHhw0gveRZ
=p9KX
-----END PGP SIGNATURE-----

Alasdair G Kergon (12):
      post-release
      conf: Add missing prefix to installation directory.
      conf: Remove exec_prefix from confdir.
      configure: Fix notify-dbus and dmfilemapd options.
      test: Skip some reshape tests that hang on single core machines
      pvresize: Prompt when non-default size supplied.
      test: Add -y to pvresize --setphysicalvolumesize
      pvresize: Missing a message on error path.
      WHATS_NEW: pvcreate --setphysicalvolumesize
      command: avoid compiler warning
      man: generate
      pre-release

David Teigland (14):
      tests: use raid_region_size 512
      configure: rename lockd to lvmlockd
      spec: rename lockd to lvmlockd
      WHATS_NEW: configure option enable-lvmlockd
      man: quote the word no
      commands: improve error messages for rules
      pvcreate: add prompt when setting dev size
      commands: improve syntax suggestion when no command is found
      WHATS_NEW: pvcreate prompt
      fix running commands from a script file
      commands: fix memory debug for cmd defs
      man lvmsystemid: general improvements
      man lvm: define LVM and its terms
      man: references to lvm entities

Heinz Mauelshagen (21):
      lvcreate: raise default raid regionsize to 2MiB
      WHATS_NEW: raise region_size default
      lvconvert: typo in message
      mirror/raid: display adjusted region size with units
      raid: avoid superfluous reload on takeover
      raid: define return value on error paths
      raid: remove double minimum area check on takeover
      test: Fix skip some reshape tests that hang on single core machines
      test: Adjust previous commit
      test: also prevent lvconvert-raid-reshape.sh on single core
      test: add upconvert allocation failure tests
      test: consider changed default
      test: add raid4 to upconvert allocation failure tests
      raid: avoid superfluous variable
      raid: handle insufficent PVs on takeover to/from raid4
      lvconvert: preserve region size on raid1 image count changes
      lvconvert: fix inactive mirror up converting regression
      lvconvert: FIXME
      Revert "lvconvert: preserve region size on raid1 image count changes"
      lvconvert: preserve region size on raid1 image count changes (v2)
      test: add -y to raid1 up conversions

Jonathan Brassow (1):
      typo: s/extends/extents/ in lvmthin man page

Marian Csontos (3):
      test: Update pattern to match code
      dbus: log_debug needs qualifier
      dbus: Add --yes when --setphysicalvolumesize is used

Tony Asleson (4):
      lvmdbusd: Make sure we don't hang on lvcreate
      lvmdbustest.py: Handle nested setUp & tearDown
      lvmdbustest.py: Add nested testing
      lvmdbusd: Improve error msg to include PV

Zdenek Kabelac (1):
      test: correcting binary usage


