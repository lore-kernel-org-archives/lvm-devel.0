From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Nov 2015 03:44:26 +0000 (UTC)
Subject: v2_02_135 annotated tag has been created
Message-ID: <20151123034426.39F7D610E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46a1ad44779476c8912f4a61ca31b31b585d7a55
Commit:        46a1ad44779476c8912f4a61ca31b31b585d7a55
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-11-23 03:38 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-11-23 03:38 +0000

annotated tag: v2_02_135 has been created
	    at 46a1ad44779476c8912f4a61ca31b31b585d7a55 (tag)
       tagging 369bc264b0db8be18243a6f95e1f6c14fdd0db99 (commit)
      replaces v2_02_134

Release 2.02.135.

Another development checkpoint: Do not ship this release.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlZSioAACgkQIoGRwVZ+LBc5FACgtrDRjBiHZTVEIGysRnd+Zzue
70wAoJEv0fHy8qDzIIorDeFm3lD309kc
=IfgX
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      coverity: Add placeholder modelling file.
      pvmove: Remove unused find_pvmove_lv_from_pvname.
      pre-release

David Teigland (18):
      lvmlockd: shut up warnings
      lvmlockd: fix the NO_GL_LS condition
      lvmlockd: reverse some unnecessary checking
      lvmetad: change recent cleanups
      vgrename: check if new and old names match
      lvmetad: tail chasing to shut up coverity
      lvmetad: handle duplicate VG names
      tests: allow lvmetad tests with duplicate VG names
      lvmetad: change the new hash to take data len
      hash: add comment about multiple values
      lvmetad: remove unneeded FIXME
      lvmetad: use lookup_withval in another location
      lvmetad: fix some error logging
      lvmetad: add error explaining duplicate VG names
      lvmetad: different style for hash functions
      lvmetad: improve error message for VGs with same name
      hash: change name of new lookup function
      tests: update lvmcache-exercise

Marian Csontos (2):
      tests: add missing --skip option and S env.variable
      tests: stacktrace on skip if message is empty

Peter Rajnoha (4):
      dev-ext: issue error if external_device_info_source=udev and udev db record incomplete
      configure: check for udev_device_get_is_initialized is available
      str_list: do not support str lists without mempools
      libdm: report: consolidate use of string list selection structures

St??phane Aulery (2):
      clvmd: remove -v option from getopt
      man: improve cmirrord.8 manpage

Zdenek Kabelac (97):
      configure: report whether to build lvmlockd
      libdevmapper-event: fix fifo leak on error path
      dmeventd: reorder tou
      dmeventd: open fifo in one function
      clvmd: check for pthread_create status
      dmsetup: check for NULL from dm_task_get_ioctl_timestamp
      dmsetup: add missing checks for dm_stats_create() ret value
      lvmetad: check for allocation fail
      lvmetad: require meta_lookup
      lvmetad: check for pointers not NULL
      lvmetad: validate mda is not NULL
      lvconvert: add extra check for existance of pointer
      libdm: add missing error path check
      libdm: ensure vars are initialized
      libdm: exlicitly check for NULL
      libdm: add test for  dm_task_get_message_response()
      thin: fix error path mem leak
      dev-type: fix TOCTOU order
      lv_manip: do not deref NULL for debug message
      report: add extra pointer check
      devmanager: validate target params
      toollib: add missing check for lvmcache_init()
      cleanup: relocate error capture
      alloc: use own mem pool for alloc_handle
      cleanup: drop unneded assign
      cleanup: do not test alloca for NULL
      cleanup: use NAME_LEN buffer instead of alloca
      cleanup: use NAME_LEN
      cleanup: use display_lvname
      cleanup: drop unneeded header file
      cleanup: use 64bit multiply for print
      cleanup: keep using enum typedef
      cleanup: drop unneeded assign
      cleanup: use fputs for plain strings
      cleanup: coverity quiet
      cleanup: reoder rstatus init
      cleanup: use code in place
      raid: mark intententional copy and paste
      lvmetad: maintain seqno as int
      dmsetup: cleanup warn for older compilers
      cleanup: update comment
      tests: do not skip test when delay is missing
      tests: update test to check for race better
      lvmetad: restore use of FMTd64
      libdaemon: prohibit use of %d for 64bit numbres
      libdaemon: fix passing 32bit values for %d
      dmsetup: one missed dms
      cleanup: drop unneded headers
      cleanup: use _ for local function
      lvmlockd: add missing error checks
      lvmlockd: enforce 64bit arithmetic
      cache: ensure there is no NULL str
      cleanup: ensuring string is not NULL
      tests: handle missing delay_dev
      libdm: replace assign with increment
      raid: fix the string compare
      libdm: reorder error path
      dmeventd: fix check for failing open.
      reporter: add missing stack trace
      libdm: put in secure check
      raid: ensure area_count is at least 2
      debug: put stack on error path
      cleanup: drop unneded check for mem
      cleanup: missing check for PV2
      cleanup: check LVs in one statement
      cleanup: better error message
      tests: without delay_dev skip some checks
      coverity: hint
      coverity: model some function
      coverity: add few internal errors
      cache: handle older metadata format
      libdm: check if passed return pointer is not NULL
      libdm: check for null from pool strdup
      libdm: check for passed custom time value
      config: check vdef pointer before dereference
      format-text: ensure no division by zero
      cleanup: add _free on error path
      cleanup: simplify dev_cache_exit
      cleanup: just alphabetically sort links
      debug: lvconvert add missing display_lvname
      coverity: model FD_ZERO
      libdm: better error reporting from dm_split_lvm_name
      libdm: fix check of pointer
      libdm: update error message
      raid: drop unneeded NULL test
      cleanup: unify NULL custom check
      cleanup: do not call vg_read with NULL mda
      cleanup: add some test for NULL
      cleanup: more readable code
      cleanup: use embeded list
      coverity: trying different model
      cleanup: use display_lvname in pmspare
      cleanup: add stack traces
      cleanup: cast resulting value explicitely
      cache: enable raid conversion for _cdata and _cmeta
      cache: lvconvert repairs only thin pools
      tests: more cache conversion checks


