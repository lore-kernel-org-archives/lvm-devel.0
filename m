From: Marian Csontos <mcsontos@sourceware.org>
Date: Sat, 15 Jun 2019 03:35:25 -0400
Subject: v2_03_05 annotated tag has been created
Message-ID: <201906150735.x5F7ZPdP001305@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=68328990621ce3af85601967de570741c3831392
Commit:        68328990621ce3af85601967de570741c3831392
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-06-15 07:23 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-06-15 07:23 +0000

annotated tag: v2_03_05 has been created
	    at 68328990621ce3af85601967de570741c3831392 (tag)
       tagging 60bd9e8406ac28a04aa5e8165149f7a5d4f3265a (commit)
      replaces v2_03_04

Release 2.03.05

Change when and how VG metadata are repaired:

- Move metadata repairs from VG reading to VG writing.
- Report/display/scan commands that read VGs will no longer write/repair.
- Improve VG reading to work if one good copy of metadata is found.
- Add vgck --updatemetadata command that will repair metadata problems.

MD component detection improvements:

- Add config setting md_component_checks to control MD component checks.
- Add end of device MD component checks when dev has no udev info.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJdBJ5yAAoJELkRJDHlCQOf+MgP/jCl0oGS/GvWmSiMlUdeioWy
SY+yqvYPa5fNnFjIg4qalJJLfooBJuTZQNjYaasB4qyKNrqYEnlVS1gt+GLHE29C
v/vDG6Q+Gcr32CqWT8sJR/x08mwPXjpWQwh74gHQ4/L7Vgau1/i8Ca4FFJS2KKlI
tAoX2StlaVTz5zrqozLCLV7ZYCijHXF+9Hwyw63zMeZ80lDEauCbVLfJnN+ZrCI4
Rb0pxVs88R8z4KeKWHrHTGBKvT9kmOMoe8msavRP9LGX+Icdcjr6/VSOfw4hDdZo
PsXDMJvermOGV2YtQiEkpY+tQ1SvrbOtpL5xeLAvRPI661zznD+AaysayOkSa0wT
HobkEnIUYV3Caj/Ud9fG51k6SFPxNIfjQZka2/pmdZe5RCfi5zRnUNeXLl/+WscD
0UVc+Zp66op8RoBBV9A/ITMkRWcC20d/h8WmjbiIuCLPphCaUlqOcwZZ3DGZ8NLe
yKXwDmT7XqKg4lUMF+OTilx1w4wjErdQi7k44JD9fzyoWeIq5BcmGAtPzXrbhBfu
lEA26/yq5tcnO8SWvoCrjgr6yPvcr0uDBSbN5Fo/7LFnXcE7eKbfSX9gVMyea8JW
VNxB/NawB00b0/kJL86QxuKnDPNFt+iJ7xSNWTIapGBxRtDdkqvfhYz+a3ZzntRE
3uxcDwroL4bnHGKFI7lP
=OoQQ
-----END PGP SIGNATURE-----

David Teigland (35):
      Additional MD component checking
      add flags to keep track of bad metadata
      ability to keep track of bad mdas in lvmcache
      ability to keep track of outdated pvs in lvmcache
      keep track of which mdas have old metadata in lvmcache
      add mda arg to add_mda
      change args for text label read function
      fix vg_commit return value
      create separate lvmcache update functions for read and write
      move wipe_outdated_pvs to vg_write
      process_each_pv handle outdated pvs
      move pv header repairs to vg_write
      vgck --updatemetadata is a new command
      vgcfgbackup add error messages
      add a warning message when updating old metadata
      improve reading and repairing vg metadata
      metadata.c: removed unused code
      tests: add missing-pv missing-pv-unused
      tests: add metadata-old.sh
      tests: add outdated-pv.sh
      tests: add metadata-bad-text.sh
      tests: add metadata-bad-mdaheader.sh
      locking: reset global_ex flag at end of cmd
      reset cmd wipe_outdated_pvs
      lvmcache: remove unused code
      vgsplit: simplify vg creation
      lvmcache: remove unused function
      locking: fix repeated convert to ex
      fix command definition for pvchange -a
      remove unused trustcache option
      lvmcache: remove wrapper around lvmcache_get_vgnameids
      vgchange: change debug message level
      tests: aux have_writecache
      WHATS_NEW for recent changes
      fix man page generation

Marian Csontos (4):
      post-release
      Merge remote-tracking branch 'origin/master'
      build: make generate
      pre-release

Zdenek Kabelac (1):
      tests: correct checked target name


