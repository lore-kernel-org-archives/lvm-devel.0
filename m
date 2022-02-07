From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  7 Feb 2022 17:08:19 +0000 (GMT)
Subject: v2_03_15 annotated tag has been created
Message-ID: <20220207170819.7C6E03858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=890c0635554075e122ef5437b5dfb28ff6fcb128
Commit:        890c0635554075e122ef5437b5dfb28ff6fcb128
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2022-02-07 17:02 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2022-02-07 17:02 +0000

annotated tag: v2_03_15 has been created
	    at 890c0635554075e122ef5437b5dfb28ff6fcb128 (tag)
       tagging 6987f318ec135ffd54a05872a8aa621726fe7acb (commit)
      replaces v2_03_14

Release 2.03.15

WARNING: This release removes service based autoactivation.
global/event_activation = 0 does nothing, user is responsible to
activate any volumes.

- Removed service based autoactivation.
- New man page lvmautoactivation(7).
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmIBUZcUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA58IrxAAy5zBVWdMRNTClJQYv/zr5EfuIszP
Z7EqUUr6beDuUSqg8QbW7i3JFcOhdXEYnIyIVNueB/YoJEPmv2ylcaMSwkZ0mmHS
FMmvGUX9w3Ze8zZda0i/zRa3kK12uy+1eOPg0stIpm3L7wORp0b1HeG4V3ceVj3v
ZujQDpn+7+Bq1+gucOup76ynacTuirGYgvXsdf3XZYWhZek2UaLmU172y8tor/ZG
vHPOqXlpgfmO78Memx1WeEW7EBwP1FmuP9rO1ZksjCx01EdKe6buKnEJdticikH3
bjGPFPrY8RxLgoqUDe8dNQ408FrhzBKJTyBEXL+YBux80CB/f/eSweSZGlZ1R+/d
6XfM7L0uBtEP+RaBDxEUZXeqpaA3h6acLNXnlZ3cTsPBt2dOsEIss/F4CyfV+RFP
56JgfgVMcHvwyvVkSP4QAnmEatEsVvr2w4P9eG5NpugWwugltEbzyLP+ItYU5g1K
8+vchwd17qTsDojmMsnJAiKxwLm+rm4M6kKvOllr14o6cCDAh9xS3TN/LJhLas4n
q5gsGzTcuO4XcVPOeOELs8nQCbbGLZ9+zcvKcTqGXOs1EDuSLW54toBYzmDQZPkH
I/pFt4RDZpyXFCrS/UV5yhKNYyEkAuKvJVGki6pglQezVxhC72hjRkxxNTN1U9Au
LJuVu51Gfr4kiDI=
=h5AN
-----END PGP SIGNATURE-----

Andrew Walsh (1):
      vdo: ensure VDO config is removed

Christian Hesse (1):
      The path is known anyway and should be the bullet proof option.

David Teigland (64):
      pvscan: fix messages from coverity changes
      vgimportdevices: skip lvmlockd locking
      hints: remove the cmd hints list
      filter-sysfs: skip when device id is set
      lvmdevices: increase open file limit
      add hints interface to the pvs_online file information
      rename pvscan_cache_single to expect_missing_vg_device in cmd
      vgchange -aay: optimize device scan using pvs_online files
      move code from pvscan.c to online.c
      lvm2-pvscan: include --autoactivation event
      vgchange -aay: optimize device list using pvs_online files
      fix device name from devno for partitions
      vgchange -aay: fall back to dev_cache_scan if optimization fails
      vgchange -aay: improve unexpected command variations
      pvs_online: include devname in pvid files
      filter-sysfs: support old kernels without sys/dev/block
      vgchange: move autoactivation setup code
      vgchange autoactivation: lock vg early to avoid second label scan
      tests: udev-pvscan-vgchange fix wait
      tests vgchange-pvs-online: clean up with devices file
      pvscan: consistent creation of pvs_lookup file
      online files: fix vgname check
      tests: udev-pvscan-vgchange clear services
      device_id: match different dm device names
      vgchange autoactivation: error path cleanup
      tests devicesfile-devname: remove searched_devnames
      device_id: fix search on filtered device
      device_id: searched_devnames improvements
      tests pv-ext-flags: work with devices file
      Revert "tests devicesfile-devname: remove searched_devnames"
      display: ignore --reportformat
      devices: exclude multipath components based on matching wwid
      fix spelling of pruning
      devices: exclude md components when duplicate pvs are seen
      man: lvmautoactivation
      pvscan: match device arg to filter symlink
      pvscan: limit md device_hint for slow autoactivation
      tests devicesfile-devname.sh drop mdadm chunk
      devices file: don't write in test mode
      pvscan: fix filter symlink checks
      pvscan: fix error message for invalid devname
      print warning about unrecognized journal option value
      device_id: handle wwid with spaces or control characters
      man: add section about static autoactivation
      lvcreate: include recent options
      udev: remove -r from systemd-run
      man lvmautoactivation: replace systemctl with journalctl
      lvmlockd: cleanup after sanlock_rem_lockspace error
      handle duplicate vgids
      Revert "handle duplicate vgids"
      vgsplit: don't reread vg_to
      lvmcache: remove lvmcache_update_vg_from_write
      handle duplicate vgids
      remove unused variable
      pvcreate: overwrite partition header with -f
      lvmdevices check: error exit if update is needed
      Revert "pvcreate: overwrite partition header with -f"
      device_id: fix search for renamed device when the wwid is ignored
      lvmdevices: fix checks when adding entries
      remove static autoactivation
      Revert "writecache: handle options from lvm.conf"
      writecache: look for settings in lvm.conf
      lvmdevices: make deldev work for missing device
      tests: devicesfile-edit

Marian Csontos (3):
      post-release
      spec: Add lvmautoactivation man page
      pre-release

Martin Wilck (1):
      udev: create symlinks and watch even in suspended state

Zdenek Kabelac (23):
      toollib: avoid repeated remove of online vg
      hash: raise hash table size
      toolcontext: reuse destroy_config_context
      activate: cache driver_version result
      libdm: correct version check
      lvmcmdline: comment reset of configuration settings
      activate: device_is_usable
      libdm: unmangling UUID for DM_DEVICE_LIST
      devicemapper: add dm_task_get_device_list
      activate: add get_device_list
      label: cache dm device list
      writecache: handle options from lvm.conf
      lvcreate: fix crash for unspecified LV name for writecache
      lvcreate: cachesettings works also with writecache
      man: doc writecache profile support
      test: check writecache profile support
      lvcreate: code move
      gcc: snprintf may need here upto 18 bytes
      gcc: increate buffer sizes
      test: remove leaked exit
      tools: missing sync after deactivation
      activation: use lv_is_active
      tests: skip test part when missed in kernel

?????? (1):
      devices: recognise rbd (ceph rados block device)


