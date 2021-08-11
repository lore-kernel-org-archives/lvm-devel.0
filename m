From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Aug 2021 15:39:35 +0000 (GMT)
Subject: v2_03_13 annotated tag has been created
Message-ID: <20210811153935.EDBA03857413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91a82455813bebce0949cb681369f370ce3105d5
Commit:        91a82455813bebce0949cb681369f370ce3105d5
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2021-08-11 15:36 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2021-08-11 15:36 +0000

annotated tag: v2_03_13 has been created
	    at 91a82455813bebce0949cb681369f370ce3105d5 (tag)
       tagging 67a853f3376059dc7022b544b7b6dae6a5e262d3 (commit)
      replaces v2_03_12

Test Release 2.03.13

WARNING: This release is intended mainly for testing.

Less reliance on udev:
- Users suffering from udev timeouts are sometimes recommended to change the
  obtain_device_list_from_udev configuration option to 0. This is now default
  and /dev is read instead of udev.
- Use of multipath wwids file to quick check if device is multipath.

See devices/external_device_info_source, devices/obtain_device_list_from_udev,
and devices/multipath_wwids_file help in lvm.conf

Other changes worth highlighting:

- Refactoring of archive() and backup() internal calls.
- New vdoimport tool to convert VDO volumes to LVs (requires updated kernel and
  vdo tools.)

And many fixes, improvements, and clean ups.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJhE+6bAAoJELkRJDHlCQOf18MQAPrVDEvyF5dj6q/agq9+Za2B
LS3xlfZjrbUip16W9TJ2JBHiLSNe4U+CLC30XMy/CH9lWQ5zkuP5dpUiRt6YDrL8
5WWGqQpR7wSj1noNyElBcObOzGhKBpQtGx4IoiKrbaZYxOgDm3j0oo5IH6uxNy3e
Ku2x0CvYZYbO0q1fOTXv67YzIUQrheEMr2sn+/4g9MkozAddsfRQYphKsHEkXuVH
YHWadDxYHSGvNNb4dPVXDKIPtFFMwaX5QzTPjW0QEtjGSh4JKtW0dknHY0y78R2G
ePvSO9g9W/msF5wGR4agHhVOJqPuEQ8HdHAlqQXyZEiJbfD2WpdfZ91oBT8Xl59S
8B3WpM58L/f4QCLbwR39F4ntfoWw1k9IZ4bnoktgOYcX+kVSgSl7IskrFrk4qchZ
rzaqvcNjdcyH4GLEJdW9pfiSBhGkChql0wkgp1qOJalMOQVDaJtH7oocxyK1U7VA
Ra+TI4NyMYCbM5stcrZiIa24Cqo49i+hfrEKj0nRIU2kuSAWFJPocDuil/1BYZ8c
kMlIILoE3qODXXdxV9HQ2xxEHGsoA8RC5/uwwRXWv6VrFXbbn/p1VZSyg4Vlocjq
PNGglK6f5ALjZq9q+FmK3cLU4EGHwnU+YlDbW3+FFmSiMgs9Fr5faGPfWt/EqscX
I2UcqsgeWk9pJKR+rMk6
=nu52
-----END PGP SIGNATURE-----

David Teigland (36):
      enable command syntax for thin and writecache
      lvremove: fix removing thin pool with writecache on data
      writecache: fix lv_on_pmem
      writecache: don't pvmove device used by writecache
      pvchange: fix file locking deadlock
      fix empty mem pool leak
      tests: writecache-blocksize add dm-cache tests
      tests: rename test
      tests: add writecache-cache-blocksize-2
      devices: don't use deleted loop backing file for device id
      man/help: fix common option listing
      lvmdevices: add deviceidtype option
      tests: add some LVM_TEST_LOCK_TYPE_IDM
      tests: fix skip in stress_single_thread.sh
      coverity cleanups
      lvconvert: allow writecache with other thinpool command syntax
      device_id: handle scsi_debug wwid
      writecache: use block size 4096 when no fs is found
      device_id: handle qemu wwid
      tests: skip tests that require blkid BLOCK_SIZE
      scan: don't hold bcache block during scan
      scan: retry reading metadata on error
      scan: move metadata vgname check
      pvscan: skip indexing devices used by LVs
      skip indexing devices used by LVs in more commands
      devices: rework libudev usage
      filter-usable: remove udev dev size check
      fix multipath component detection for multiple holders
      pvscan: do nothing for device removal and event_activation=0
      pvscan: narrow the previous commit slightly
      writecache: fix missing sync_dev_names when attaching cache
      writecache: use block size 512 for thin pool data
      cov: lvmlockd path copy
      devices file: limit warnings about devices file entries not found
      devices file: avoid updating entry dev names in some cases
      pvscan: only match devices file for command args

Heming Zhao (1):
      toolcontext: fix double free (core dumped) issue

Leo Yan (26):
      lvmlockd: idm: Introduce new locking scheme
      lvmlockd: idm: Hook Seagate IDM wrapper APIs
      lib: locking: Add new type "idm"
      lib: locking: Parse PV list for IDM locking
      tools: Add support for "idm" lock type
      configure: Add macro LOCKDIDM_SUPPORT
      tests: Enable the testing for IDM locking scheme
      tests: Support multiple backing devices
      tests: Cleanup idm context when prepare devices
      tests: Add checking for lvmlockd log
      tests: stress: Add single thread stress testing
      tests: stress: Add multi-threads stress testing for VG/LV
      tests: stress: Add multi-threads stress testing for PV/VG/LV
      tests: Support idm failure injection
      tests: Add testing for lvmlockd failure
      tests: idm: Add testing for the fabric failure
      tests: idm: Add testing for the fabric failure and timeout
      tests: idm: Add testing for the fabric's half brain failure
      tests: idm: Add testing for IDM lock manager failure
      tests: multi-hosts: Add VG testing
      tests: multi-hosts: Add LV testing
      tests: multi-hosts: Test lease timeout with LV exclusive mode
      tests: multi-hosts: Test lease timeout with LV shareable mode
      lvmlockd: Fix the compilation warning
      tests: stress: Change to use $SHARED for vgcreate
      tests: Fix building for IDM program

Marian Csontos (4):
      post-release
      spec: Add vdoimport man page
      WHATS_NEW: update
      pre-release

Tony Asleson (4):
      lvmdbusd: Don't setup search key unless needed
      lvmdbusd: Defer dbus object removal
      lvmdbusd: Handle arbitrary amounts stdout & stderr
      lvmdbusd: Wrap json.load in try/except

Wu Guanghao (1):
      pvck: add lock_global() before clean_hint_file()

Zdenek Kabelac (32):
      vdo: fix preload of kvdo
      archiving: take archive automatically
      backup: automatically store data on vg_unlock
      archive: avoid abuse of internal flag
      config_settings: typo fix
      lvconvert: fix vdo virtual size when specified
      vdo: rename variable vdo_pool_zero
      vdo: support vdo_pool_header_size
      make: generate
      WHATS_NEW: update
      configure: updates
      vdo: add vdoimport support
      man: vdoimport page
      thin: fix component detection of external origin
      vgremove: remove forgotten pmspare
      vgsplit: add support for option --poolmetadataspare
      test
      vgmerge: remove one of merge pmspare LVs
      vgmerge: support option --poolmetadataspare
      tests: extend vgmerge testing
      cov: pvck fix memleak
      pvck: ensure buffer is 0 terminated
      cov: memleak dir descriptor
      cov: remove unneeded includes
      cov: add internal error for missing arg
      cov: ensure bufffe size is at least 5
      cov: guard index
      cov: dev-mpath: check config_wwids_file
      cov: raid: no more checks with missing areas
      cov: add explicit check for vg existence
      cov: add initilizer
      debug: stack tracing on error path

root (1):
      make: generate


