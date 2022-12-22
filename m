From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 22 Dec 2022 15:12:06 +0000 (GMT)
Subject: v2_03_18 annotated tag has been created
Message-ID: <20221222151206.BE7F73858425@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fba794b52541452da9131af594f5cd0fa7affb6d
Commit:        fba794b52541452da9131af594f5cd0fa7affb6d
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2022-12-22 15:09 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2022-12-22 15:09 +0000

annotated tag: v2_03_18 has been created
	    at fba794b52541452da9131af594f5cd0fa7affb6d (tag)
       tagging 2772d299174c25f054b4e5ceb0e86aec661b12f6 (commit)
      replaces v2_03_17

Release 2.03.18

Bugfix release.
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmOkc0gUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA5/krRAA912NJ1eyB0Mve6fKEJ/lk149s9e+
9Y5zTzzZOgvwA4msM+HR2dmYk9Sio79nv5ep/uLeSHkmjWp+6lzrWPH0WrZ46mhM
6wRR7MJgzAL+eb3dBuov+FC9GCgVdEfijsdzSXjt2L/s1/YCyU8bBcyZEHKKUBsB
wA2etif3DM8rbAczJnsO2zfHAA+GASF5KhO9tu+xf29YUvzYnHAGUgnF3BQzObG2
bpY/UZyIodjGbWZzS6ax4Xd92qoEL2aaVEeHK4va1cGDxxP+TpVUC2lWKwMM/ONF
T82b0pyXmTo6YNR7urRBBJa15R32Qmha5YvGriwAfVsckq1hur+ic76WYmJ7MIGW
/iU/B+2imc0NfG92/5ALzigosF2cu7ja2/HF/pNN1m7ZjRkj2APpI/PGIq29l9D4
G7WXppU5tYPzxfy78+mduWPjtz57KD/VXgZ09hCP2TxYEWasAZ/8InFHDG02ATc7
DLFZ1sqLI2adyAsTlIjMsQLU8HElKEKG0jAOgxPZqHg6nUJXmQae1RuhEGXYBjPj
4lqL1qQ9hdpV80j9qWf91LV2eHJYaYRT7wBnI9NqKpM/VY28jUhJE3Lt+l5D0SVS
tFh5xOXdAO3btMxqJknSNxqdlDcn3aXCDLENV/o6ZM38+Kzzym4oHfkySZobgVoT
xu4wKvFdxsqaMQw=
=xtda
-----END PGP SIGNATURE-----

David Seifert (1):
      configure: allow for overriding of `readelf`

David Teigland (10):
      tests: devicesfile-vpd-ids add nvme wwid
      lvmlockd: fix missing closedir
      lvmcache: fix strncpy len for wwid
      device_id: add null id->name null check
      device_id: _get_devs_with_serial_numbers add missing free
      device_id: check return value of label_read_pvid
      device_id: fix segfault verifying serial for non-pv
      lvchange: handle unrecognized writecache setting
      writecache: support settings metadata_only and pause_writeback
      lvextend: fix overprovisioning check for thin lvs

Marian Csontos (2):
      post-release
      WHATS_NEW: update

Sam James (1):
      lvmpolld: fix `strerror_r` check for musl

Tony Asleson (3):
      lvmdbustest: Add test to ensure error collection
      lvmdbusd: Move get_error_msg to utils
      lvmdbusd: Add command_log_selection to command line

Zdenek Kabelac (8):
      configure: update
      dmsetup: fix udev event handling for create
      man: dmsetup concise format consitency
      vdo: fix reader error path
      cov: remove unused header files
      cov: fix buffer size usage
      cov: use long type for time_t calcs
      pvscan: free unused device_id

corubba (2):
      report: adjust lv_active_remotely for shared VGs
      report: query lvmlockd for lv_active_exclusively

