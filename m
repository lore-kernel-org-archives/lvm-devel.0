From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 May 2022 16:26:17 +0000 (GMT)
Subject: v2_03_16 annotated tag has been created
Message-ID: <20220518162617.3F8653858016@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82b36d78165764dda7d44d104737a95054348a02
Commit:        82b36d78165764dda7d44d104737a95054348a02
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2022-05-18 16:21 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2022-05-18 16:21 +0000

annotated tag: v2_03_16 has been created
	    at 82b36d78165764dda7d44d104737a95054348a02 (tag)
       tagging 6d1e894a867681af7a811ed63bc435f3aa55fec8 (commit)
      replaces v2_03_15

Release 2.03.16

Mostly bug fixes and minor improvements.
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmKFHY4UHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA5+hpA//cpgNtNuGOD1cqIS9i6JkPNwJy4TI
HbCMqJDQqQjeOGIj/8GTnMYwvbSAgZrRL+fITvrVu24EBj7yzRvFhn0+zr6WlTAF
5MHMiRkWPzf/dZjhSMNV5XGlC1anuUBqIkRmtO5BGowPnm5ve/OH5dhGiOPdzI9m
riIWX9ZnXhjKwkXA+ovpczYbkABoahL4Of2WxReiPEAWnXBzCO2X7TQWrvZxbEzk
4s5aewphB14oEY8xnJAbt9M+te+gWk+IKmN8dCWURcPSj5zMkjW/iuDMKJee7e9o
rsYGeZJrXQCz20HfjGdtnKJMEYbEslKYOiayGBQeKLf+AIwuSOxG1zv7mSuE9MtA
HnMDwRik9S2YkpmntdTRKzjJTC2QzbAdgZ+ywdL7Xq/qTPc4rrOYfTVMSbylo28j
LZRb4hOcIeqCRv0j4Y4sazyDw1GfGcW5TrDQ/4ddWDyU+FNjCoC4BQbHdr9dxYiO
9SnAgMtbOJ25A9MnjRiq0+8+YJ4rIKo+Kp72a+v3SZI5Q+S17PiWIKtKMfWMkylb
pRaAOGLo717uqEk8pMFCgCiGhuclXZUwFWNzWbJ7c1EE6xGMZP5DJjsWxPAiPhWu
t6b1R6XrfcxwXHEbzWPjKGCpHTjgKJNaxN8HrZtvqpBQhdJ0vq/w7q/Abl3Dj5cH
jwQ85DHUtcVrfno=
=GbW6
-----END PGP SIGNATURE-----

David Teigland (31):
      tests: udev-pvscan-vgchange fix service wait
      devices file: do not clear PVID of unread devices
      tests: skip vgchange-pvs-online.sh on rhel5
      man lvmcache: add more writecache cachesettings info
      man: update cachesettings option description
      man lvmcache: mention writecache memory usage
      writecache: display block size from lvs
      devices: simplify dev_cache_get_by_devt
      devices: drop incorrect paths from aliases list
      devices: initial use of existing option
      devices: fix dev_name assumptions
      devices: use dev-cache aliases handling from label scan functions
      devices: only close PVs on LVs when scan_lvs is enabled
      writecache: check memory usage
      pvscan: don't use udev for external device info
      vgchange monitor: don't use udev info
      Move nolocking warning to man page
      fix args entry for nolocking
      devices file: warn about missing multipath entry
      lvmdevices update: correct multipath entries
      change messages about filtered devices
      pvscan: warn about /dev/sda excluded by devices file
      vgimportdevices: fix incorrect deviceidtype usage
      lvmdevices: --deldev using device id
      filter: remove unused EAGAIN case and flag
      filters: remove unused internal filter
      lvmlockd: return error from vgcreate init_vg_sanlock
      devices file: remove extraneous unlock in vgchange -u
      tests: devicesfile-edit.sh fix loop file name
      filter-mpath: use multipath blacklist
      improve description of devices option

Marian Csontos (3):
      post-release
      make: generate
      pre-release

Peter Rajnoha (1):
      toollib: fix segfault when handling selection with historical LVs

Zdenek Kabelac (11):
      asan: fix some reports from libasan
      make: generate
      dev_manager: fix dm_task_get_device_list
      dev_manager: failing status is not internal error
      clang: add extra check
      clang: possible better compilation with musl c
      dev_manager: do not query for open_count
      dev_manager: use list info for preset devs
      thin: fix message processing on thin-pool extension
      vdo: support --vdosettings
      make: generate

