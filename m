From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Sep 2015 22:57:45 +0000 (UTC)
Subject: v2_02_130 annotated tag has been created
Message-ID: <20150905225745.A67B760C1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd523f1aa2e7ac6957ee3ded127a1f0bcef84662
Commit:        cd523f1aa2e7ac6957ee3ded127a1f0bcef84662
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-09-05 22:46 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-09-05 22:46 +0000

annotated tag: v2_02_130 has been created
	    at cd523f1aa2e7ac6957ee3ded127a1f0bcef84662 (tag)
       tagging f5a3b05c7ac8474cd323558399d2886f8edb5731 (commit)
      replaces v2_02_129

Release 2.02.130.

54 files changed, 2612 insertions(+), 832 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlXrcNwACgkQIoGRwVZ+LBeVWgCeKQ8yHA6k336lieuZgDLQ3ySX
VvwAoOEJCSSMhlGE79bG1HWJR8IgTqbx
=+btw
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      man: Add install_full_man makefile target.
      libdm: Reinstate dm_task_get_info at Base.
      pre-release

Bryn M. Reeves (13):
      libdm: reset report field widths in _destroy_rows()
      libdm: add latency histogram support
      dmstats: add histogram support
      dmstats: improve stats column names
      man: update dmstats.8.in examples
      man: document --regionid in dmstats.8.in
      man: fix typo in dmstats.8.in
      libdm: allow formatting histogram strings with no whitespace
      dmstats: add --notimesuffix switch
      dmstats: support --noheadings for histogram fields
      dmstats: replace histogram command with switch
      libdm: fix uninitialized variable warnings on older gcc
      WHATS_NEW_DM: fix histogram entries for 1.02.107

David Teigland (25):
      lvmlockd: add full changing of lock type
      lvmlockd: fix dlm EAGAIN checks
      lvmlockd: fix to work around dlm lvb bug
      lvmlockd: improve VG removal for lock_type dlm
      lvmlockd: rescan lockd VG in two new cases
      lvmlockd: detect when dlm lvb is invalidated
      lvmlockd: fix function def for non-lvmlockd build
      lvmlockd: skip lockd removal check for non-lockd VGs
      lvmlockd: remove list of inactive lockspaces
      lvmlockd: fix starting dlm global lockspace
      lvmlockd: VG lock can be used when changing lock type
      man lvmlockd: various improvements
      lvmetad: also accept vg name for set_vg_info
      lvmlockd: also use vg name in set_vg_info
      lockd: vgrename fixes
      vgrename: add missing trace on error path
      lvmlockd: improve log messages for adding dlm global lockspace
      lockd: check for unlock failure in all cases
      lvmlockd: fixes for starting dlm global lockspace
      vgchange: improve error message about changing lock type
      man lvmlockd: explain the use of lvmlockctl kill
      lvmlockctl: update command descriptions and add logging
      man lvmlockctl: add man page
      man lvmlockd: add section about first sanlock VG
      lvmlockd: don't stop lockspace for EREMOVED

Ondrej Kozina (4):
      lvmpolld: make lvpoll error messages visible
      lvmpolld.8.in: add missing space
      lvconvert: skip polling in test mode
      pvmove: skip polling later in test mode

Peter Rajnoha (4):
      libdm: pkgconfig: fix devmapper.pc to not reference nonexistent rt.pc file
      filters: do not print [none:nil] as external device info's [source:handler] if "none" source is used
      dev-cache: append (major:minor) to debug messages about adding device or its alias to cache
      dev-cache: fix use of uninitialized device status if reading outdated .cache record

Zdenek Kabelac (13):
      configure: better parsing of cache_check version
      libdm: relocate parsing of thin-pool status
      filters: swap device_is_usable test
      thin: detect unusable thins
      thin: validate mapped size of thin volume
      thin: do not flush when quering for thin percent
      dmeventd: reorder mempool allocation
      lvcreate: restore missed --monitor
      cleanup: show error message
      cleanup: avoid printing -0.00
      cleanup: use just 2 decimal digits
      tests: use conv=fdatasync
      tests: update thin test


