From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 18 Jun 2014 20:41:43 +0000 (UTC)
Subject: master - test: Clean-up pvmove-basic for atomic pvmove test
Message-ID: <20140618204143.C0DC66033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57faf97e6fe9a8d7be859db2edb1ba2ad855113d
Commit:        57faf97e6fe9a8d7be859db2edb1ba2ad855113d
Parent:        e96a4856e678d84054e6c11532628e55830f2fc4
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 18 15:40:06 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 18 15:40:06 2014 -0500

test: Clean-up pvmove-basic for atomic pvmove test

The way I was testing for the existence of pvmove mimages was
incorrect for rhel5.  This patch makes it more generic/universal.
---
 test/shell/pvmove-basic.sh |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index bdfb79a..c326dc3 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -71,7 +71,7 @@ check_and_cleanup_lvs_() {
 	vgchange -an $vg
 	lvremove -ff $vg
 	(dm_table | not grep $vg) || \
-	      die "ERROR: lvremove did leave some some mappings in DM behind!"
+	      die "ERROR: lvremove did leave some mappings in DM behind!"
 }
 
 # ---------------------------------------------------------------------
@@ -346,16 +346,13 @@ pvmove $mode "$dev1"
 #COMM "pvmove fails activating mirror, properly restores state before pvmove"
 dmsetup create $vg-pvmove0 --notable
 not pvmove $mode -i 1 "$dev2"
-echo BARF
-dmsetup ls
 dmsetup info --noheadings -c -o suspended $vg-$lv1
 test $(dmsetup info --noheadings -c -o suspended $vg-$lv1) = "Active"
-if [ -e /dev/mapper/$vg-pvmove0_mimage_0 ]; then
-        dmsetup remove $vg-pvmove0 /dev/mapper/$vg-pvmove0_mimage*
+if dmsetup info $vg-pvmove0_mimage_0 > /dev/null; then
+        dmsetup remove $vg-pvmove0 $vg-pvmove0_mimage_0 $vg-pvmove0_mimage_1
 else
         dmsetup remove $vg-pvmove0
 fi
-dmsetup ls
 
 lvremove -ff $vg
 done
\ No newline at end of file


