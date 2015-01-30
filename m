From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 30 Jan 2015 16:22:31 +0000 (UTC)
Subject: v2_02_116 annotated tag has been created
Message-ID: <20150130162231.AA00B606FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af2fce769088baa24a1bda71b65180de510d3a5f
Commit:        af2fce769088baa24a1bda71b65180de510d3a5f
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-01-30 16:17 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-01-30 16:17 +0000

annotated tag: v2_02_116 has been created
	    at af2fce769088baa24a1bda71b65180de510d3a5f (tag)
       tagging d0837dcceba4d75ed722c300fdf00c52b9892da5 (commit)
      replaces v2_02_115

Release 2.02.116.

41 files changed, 995 insertions(+), 138 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlTLrsAACgkQIoGRwVZ+LBfQnwCeKaROES12Zz5c7wW8dhQfDzR7
d58AniYS6SmRodBOwlwzS01y7Y5v1fnA
=Nwa2
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      devices: Do not support unpartitioned DASD.
      devices: DASD doesn't need to be stackable.
      pre-release

David Teigland (3):
      lvmthin: update data space exhaustion
      lvmthin: update monitor and autoextend
      lvm.conf: update error_when_full description

Peter Rajnoha (16):
      config: improve config validation to check if setting with string value can be empty.
      coverity: missing return value check
      lvm2app: fix lvm_lv_get_attr regression causing unknown values
      properties: also recognize LVSINFO, LVSSTATUS and LVSINFOSTATUS as subtypes of LVS
      WHATS_NEW: previous commit
      device: add infrastructure to support external device info
      filter-composite: add external device info hooks
      conf: add devices/external_device_info_source to lvm.conf
      filter-md: use new 'udev' external device info source to get MD component status
      filter-mpath: use new 'udev' external device info source to get mpath component status
      filter-usable: move check for pv_min_size from filter-partitioned to filter-usable and use new 'udev' external device info source for this check
      filter-partitioned: use new 'udev' device status source to get partition status
      filters: add firmware RAID filter
      cleanup: add dev-ext-udev-constants.h with constants/names of the properties/values used from udev db
      WHATS_NEW
      cleanup: conf: auxiliary_device_status_source -> external_device_info_source

Zdenek Kabelac (17):
      raid: fix tree preload for splitting raid images
      raid: fix raid image splitting
      raid: lock holder will skip visible raid LVs
      cleanup: use macro lv_is_visible()
      thin: preserve chunksize with lvconvert
      cache: add pool deps for preload
      raid: preload splitted LV only when active
      cache: use writethrough cache_mode for older metadata
      lv_manip: add for_each_sub_lv_except_pools()
      cleanup: indent tabs
      tests: test stacked raid
      revert "cache: add pool deps for preload"
      raid: check lock holding LV
      thin: report proper status for thin pool
      thin: fix upgrade regression
      WHATS_NEW
      tests: add --force to sfdisk


