From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Mar 2014 13:24:48 +0000 (UTC)
Subject: master - tests: detect reiserfs support
Message-ID: <20140301132448.C820E60C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72ecf8e591d1ee6b863d814114a7a8045598efc0
Commit:        72ecf8e591d1ee6b863d814114a7a8045598efc0
Parent:        090e81281fbf88bf27ee6930dfaf03cd48aade88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 28 23:05:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 1 14:08:59 2014 +0100

tests: detect reiserfs support

Since reiserfs is not commonly available detect its presence in kernel.
Stop reporting skipped test as WARNING.
---
 test/shell/fsadm.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 13e5304..04b659f 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -29,8 +29,11 @@ which mkfs.xfs || check_xfs=${check_xfs:-mkfs.xfs}
 which xfs_check || {
 	which xfs_repair || check_xfs=${check_xfs:-xfs_repair}
 }
+grep xfs /proc/filesystems || check_xfs=${check_xfs:-no_xfs}
+
 which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
 which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
+grep reiserfs /proc/filesystems || check_reiserfs=${check_reiserfs:-no_reiserfs}
 
 vg_lv=$vg/$lv1
 vg_lv2=$vg/${lv1}bar
@@ -75,9 +78,9 @@ check_missing()
 	eval local t=$\check_$1
 	test -z "$t" && return 0
 	test "$t" = skip && return 1
-	# trick to get test listed with warning
 	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing."
-	should false;
+	# trick to get test listed with warning
+	# should false;
 	return 1
 }
 


