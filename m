From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  1 Apr 2016 19:36:52 +0000 (UTC)
Subject: v2_02_149 annotated tag has been created
Message-ID: <20160401193652.A045160E73@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a02139d22551405d4317671a312ef5cc20c2db0
Commit:        7a02139d22551405d4317671a312ef5cc20c2db0
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-04-01 19:30 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-04-01 19:30 +0000

annotated tag: v2_02_149 has been created
	    at 7a02139d22551405d4317671a312ef5cc20c2db0 (tag)
       tagging 2d0d58b8679f0d071c194db34660a112ae0f3204 (commit)
      replaces v2_02_148

Release 2.02.149.

A small development release including fixes for some recent changes.

21 files changed, 265 insertions(+), 77 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlb+zK8ACgkQIoGRwVZ+LBc/SQCfVsGYacni96Ps6N01aXCdqgFU
EHUAn25BkfYNAAbt5Ob6PIEVIaGjmzD+
=DzKi
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-commit
      Revert "thin: display highest mapped sector"
      pre-release

Marian Csontos (1):
      test: Add missing directory

Peter Rajnoha (13):
      dev-cache: handle situation where device is referenced in sysfs, but the node is not yet in dev dir
      dev-cache: also index VGIDs and LVIDs if using persistent .cache file
      dev-cache: remove spurious error msg if no value found in /sys/dev/block/<major>:<minor>/dm/uuid during dev scan
      dev-cache: dev_cache_index_devs fn is available unconditionally
      doc: describe lvmlockd/lvmpolld features as available if LVM compiled with lockd/polld support
      dev-cache: fix check for already indexed dev in _index_dev_by_vgid_and_lvid
      tests: vg-check-devs-used requires driver version 4.15 at least
      refactor: dev-cache: use btree instead of hash table for sysfs-only devices
      refactor: dev-cache: move code adding sysfs-only device into separate fn
      dev-cache: also add dev name for device found in sysfs only
      dev-cache: iterate devices in sysfs for VGID/LVID index if obtain_device_list_from_udev=0
      fix: make udev_get_library_context available also for non-udev compilations
      dev-cache: skip VGID/LVID indexing if /sys/dev/block is not present

Zdenek Kabelac (7):
      thin: no thin-pool flush when reading metadata status
      thin: display highest mapped sector
      cleanup: debug message fix
      cleanup: use TARGET define
      cleanup: use local var to read struct
      tests: do not test settings when MQ is emulated by SMQ
      tests: fixed cache target reacts faster


