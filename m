From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 09:58:25 +0000 (UTC)
Subject: master - tests: fix exporting content of make vars
Message-ID: <20131017095825.971EB61313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93a07a1b841628bb4c8caaa7f0470fc77f656ff2
Commit:        93a07a1b841628bb4c8caaa7f0470fc77f656ff2
Parent:        f9725503f86593512e9472152ce2642f4b2f414f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 10:41:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 11:57:35 2013 +0200

tests: fix exporting content of make vars

Further tune script, so it works correctly with
usable and unusable thin tools.
---
 test/Makefile.in                    |    7 ++++---
 test/shell/lvconvert-repair-thin.sh |   31 +++++++++++++++----------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 961eb9e..943a4ce 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -25,9 +25,10 @@ abs_top_builddir = "@abs_top_builddir@"
 abs_top_srcdir = "@abs_top_srcdir@"
 
 LVM_TEST_RESULTS ?= results
-LVM_TEST_THIN_DUMP_CMD ?= "@THIN_DUMP_CMD@"
-LVM_TEST_THIN_CHECK_CMD ?= "@THIN_CHECK_CMD@"
-LVM_TEST_THIN_REPAIR_CMD ?= "@THIN_REPAIR_CMD@"
+export LVM_TEST_THIN_CHECK_CMD?=@THIN_CHECK_CMD@
+export LVM_TEST_THIN_DUMP_CMD?=@THIN_DUMP_CMD@
+export LVM_TEST_THIN_REPAIR_CMD?=@THIN_REPAIR_CMD@
+
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 225dcc8..aa301d6 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -14,18 +14,14 @@
 
 . lib/test
 
-# Set tools from configuration (set by Makefile)
-# Allow user override to take tools from unusual places
-LVM_TEST_THIN_CHECK_CMD=${LVM_TEST_THIN_CHECK_CMD:-thin_check}
-LVM_TEST_THIN_DUMP_CMD=${LVM_TEST_THIN_DUMP_CMD:-thin_dump}
-LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD:-thin_repair}
-
 which mkfs.ext2 || skip
 
-# Maybe check also version of the tools here??
-which $LVM_TEST_THIN_CHECK_CMD || skip
-which $LVM_TEST_THIN_DUMP_CMD || skip
-which $LVM_TEST_THIN_REPAIR_CMD || skip
+# By default use tools from configuration (exported through Makefile)
+# Allow user to override location of binaries to take tools from different laces
+# Maybe check also version of the tools here?
+test -n "$LVM_TEST_THIN_CHECK_CMD" || LVM_TEST_THIN_CHECK_CMD=$(which thin_check) || skip
+test -n "$LVM_TEST_THIN_DUMP_CMD" || LVM_TEST_THIN_DUMP_CMD=$(which thin_dump) || skip
+test -n "$LVM_TEST_THIN_REPAIR_CMD" || LVM_TEST_THIN_REPAIR_CMD=$(which thin_repair) || skip
 
 #
 # Main
@@ -76,6 +72,8 @@ should not $LVM_TEST_THIN_DUMP_CMD $DM_DEV_DIR/$vg/repair | tee dump
 
 should $LVM_TEST_THIN_REPAIR_CMD -i $DM_DEV_DIR/$vg/repair -o $DM_DEV_DIR/$vg/fixed
 
+should $LVM_TEST_THIN_DUMP_CMD --repair $DM_DEV_DIR/$vg/repair | tee repaired_xml
+
 should $LVM_TEST_THIN_CHECK_CMD $DM_DEV_DIR/$vg/fixed
 
 # Swap repaired metadata back
@@ -90,13 +88,14 @@ dmsetup table
 dmsetup info -c
 dmsetup ls --tree
 
-# Currently in troubles - we can't remove thin volume from broken pool
-lvchange -an $vg/repair
-lvchange -an $vg/fixed
-lvchange -an $vg/pool_tmeta0
-dmsetup remove $vg-pool_tdata
-dmsetup remove $vg-pool_tmeta
+lvchange -an $vg
+
+# FIXME: Currently in deep troubles - we can't remove thin volume from broken pool
+should lvremove -ff $vg
 
+# let's not block PVs with openned _tdata/_tmeta devices
+dmsetup remove $vg-pool_tdata || true
+dmsetup remove $vg-pool_tmeta || true
 
 dmsetup table
 


