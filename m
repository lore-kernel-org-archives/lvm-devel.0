From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 May 2016 23:59:44 +0000 (UTC)
Subject: v2_02_153 annotated tag has been created
Message-ID: <20160506235944.B6B9B61BB2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cab5766ada282979c83db33d0384ad212888f13
Commit:        7cab5766ada282979c83db33d0384ad212888f13
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-05-06 23:37 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-05-06 23:37 +0000

annotated tag: v2_02_153 has been created
	    at 7cab5766ada282979c83db33d0384ad212888f13 (tag)
       tagging e4caf0beebd3718bf77a04905ed2f65712707a5d (commit)
      replaces v2_02_152

Release 2.02.153.

A development release with improvements in duplicate PV detection and
handling.  Duplicate PVs might be different paths to the same device or
cloned devices and these two cases need to be treated differently.  If
the code couldn't tell, it used to assume multipath rather than clones,
but now it wants you to resolve the problem yourself - run multipath or
vgimportclone or configure filters to hide devices.
(A configuration setting lets you return to something close to the
previous behaviour.)

44 files changed, 1641 insertions(+), 839 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlctLSgACgkQIoGRwVZ+LBfz6ACfVeFy36HH+9c7qNDH+Q3CJYhq
ursAoOn0v+XSEoy4nxr2WFd0GLzUBwdS
=Qs4F
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (20):
      pvcreate, pvremove: translate arg name to device once
      pvcreate: improve debug message
      pvscan: fix errors for single dev scan while lvmetad is disabled
      lvmetad: set disabled flag in lvmetad if duplicate PVs are found
      lvmetad: set disabled flag when duplicate PVs are seen
      lvmetad: remove client side altdev code
      lvmcache: improve duplicate PV handling
      lvmcache: process duplicate PVs directly
      pvs: new attr and field for unchosen duplicate device
      lvmcache: use active LVs and device sizes to choose between duplicates
      lvmetad: disable if device scan fails
      lvmetad: add duplicate resolution advice
      test: process-each-duplicate-pvs
      test: pv-duplicate-uuid
      test: lvmetad-ambiguous
      test: vgsplit-usage
      test: vgcfgbackup-usage
      test: vgcfgbackup-lvm1
      metadata: move warning message about repairing VG
      WHATS_NEW: duplicate PVs

Zdenek Kabelac (18):
      cache: function for min metadata size estimation
      cache: add validate_lv_cache_chunk_size
      cache: add cache_set_params function
      cleanup: gather version info with single check
      cache: use target_present_version
      debug: enhance debug msg for cache
      lvcreate: check for lv type and created segtype
      lvcreate: improve --chunksize support for cached volume.
      cleanup: just switch error path
      cleanup: enhance warning message
      cleanup: use unsigned with EPOCH printf format
      tests: check for thin tools
      tests: check default policy is used when unspecified
      tests: update aux raid support
      tests: do not use EPOCH for get wrapper
      segtype: check for activation2
      cleanup: drop tracing
      activation: activation check is mandatory


