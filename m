From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Sep 2019 07:19:04 -0400
Subject: master - tests: check vdo
Message-ID: <201909171119.x8HBJ4Br025651@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38a3da532f27a8ccda652842bb89dbecb1e4a3f9
Commit:        38a3da532f27a8ccda652842bb89dbecb1e4a3f9
Parent:        6612d8dd5e77eab1b24cafccffa83e65a504c94f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 14 09:50:18 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 13:17:21 2019 +0200

tests: check vdo

---
 test/shell/lvchange-vdo.sh |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvchange-vdo.sh b/test/shell/lvchange-vdo.sh
index 6d2b451..461b782 100644
--- a/test/shell/lvchange-vdo.sh
+++ b/test/shell/lvchange-vdo.sh
@@ -27,26 +27,26 @@ lvcreate --vdo -L5G -n $lv1 $vg/vdopool
 # Wait till index gets openned
 for i in {1..10} ; do
 	sleep .1
-	check grep_dmsetup status $vg-vdopool " online online " || continue
+	check grep_dmsetup status $vg-vdopool-vpool " online online " || continue
 	break
 done
 
 
 # compression_ARG
 lvchange --compression n $vg/vdopool
-check grep_dmsetup status $vg-vdopool " online offline "
+check grep_dmsetup status $vg-vdopool-vpool " online offline "
 lvchange --compression y $vg/vdopool
-check grep_dmsetup status $vg-vdopool " online online "
+check grep_dmsetup status $vg-vdopool-vpool " online online "
 
 # dedulication_ARG
 lvchange --deduplication n $vg/vdopool
-check grep_dmsetup status $vg-vdopool " offline online "
+check grep_dmsetup status $vg-vdopool-vpool " offline online "
 lvchange --deduplication y $vg/vdopool
-check grep_dmsetup status $vg-vdopool " online online "
+check grep_dmsetup status $vg-vdopool-vpool " online online "
 
 
 lvchange --compression n --deduplication n $vg/vdopool
-check grep_dmsetup status $vg-vdopool " offline offline "
+check grep_dmsetup status $vg-vdopool-vpool " offline offline "
 
 
 lvchange -an $vg/$lv1
@@ -117,6 +117,25 @@ not lvchange --zero y $vg/$lv1
 not lvchange --resync -ay $vg/$lv1
 not lvchange --resync --addtag foo $vg/$lv1
 
+# Check activation of VDO alone works (like for thin-pools)
+lvchange -an $vg
+
+lvchange -ay $vg/vdopool
+check active $vg vdopool
+check inactive $vg $lv1
+
+lvchange -ay $vg/$lv1
+check active $vg $lv1
+
+lvchange -an $vg/$lv1
+check active $vg vdopool
+check inactive $vg $lv1
+
+lvchange -ay $vg/$lv1
+lvchange -an $vg/vdopool
+lvchange -an $vg/$lv1
+check inactive $vg vdopool
+
 #
 # Play with tags and activation
 #


