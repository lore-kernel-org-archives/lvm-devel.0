From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 10 Jun 2016 23:16:13 +0000 (UTC)
Subject: v2_02_156 annotated tag has been created
Message-ID: <20160610231613.E215D61F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc2a9aaa637ffc7b38829dba86a30ddd22fe4c75
Commit:        dc2a9aaa637ffc7b38829dba86a30ddd22fe4c75
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-06-10 23:08 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-06-10 23:08 +0000

annotated tag: v2_02_156 has been created
	    at dc2a9aaa637ffc7b38829dba86a30ddd22fe4c75 (tag)
       tagging f2d1f5e9273232fccc05cc819b28ea47f7da7ff9 (commit)
      replaces v2_02_155

Release 2.02.156.

Another development release with an assortment of bug fixes and some
extensions to the not-yet-finalised D-Bus support.

29 files changed, 939 insertions(+), 307 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAldbSQgACgkQIoGRwVZ+LBd0HwCeIcQOovZtM4ES7zipS5Tdeb3l
iLoAn0o/0C1bkpTIOcm0F1CBtrOkr6nB
=gbnf
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (7):
      lvmetad: define special update in progress string
      lvmetad: remove disabled case for "scan error"
      lvmetad: handle update failures
      lvmcache: add optional dev arg to lvmcache_info_from_pvid
      lvmcache: fix duplicate handling with multiple scans
      vgcreate, pvcreate, vgextend: don't use a device with duplicates
      WHATS_NEW: add recent changes

Peter Rajnoha (2):
      blkdeactivate: fix regression in blkdeactivate causing dm and md devices to be skipped.
      lvmdump: also collect output from lsblk command when running lvmdump -s

Tony Asleson (9):
      lvmdbusd: Add roles property to LV common interface
      lvmdbusd: Add data_lv and metadata_lv to cache pool interface
      lvmdbusd: Bug fix for missing LV properties
      lvmdbusd: Change print statement to py3 syntax
      lvmdbusd: Rename get_object_path_by_lvm_id
      lvmdbusd: Add method get_object_path_by_lvm_id
      lvmdbusd: Create correct LV object type
      lvmdbusd: Add test for DataLv & MetaDataLv
      lvmdbusd: Remove duplicate test code

Zdenek Kabelac (2):
      display: yes no prompt improvement
      cleanup: typo in WHATS_NEW_DM


