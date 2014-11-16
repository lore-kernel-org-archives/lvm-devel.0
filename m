From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 16 Nov 2014 23:45:22 +0000 (UTC)
Subject: master - tests: thin repair testing
Message-ID: <20141116234522.75F4E60EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=740fcdae7d44ae2398ea427f91fc87195e449d42
Commit:        740fcdae7d44ae2398ea427f91fc87195e449d42
Parent:        3a1c609ac49852b50d45a4dd292a61b7cbb9c25f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 17 00:41:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 17 00:41:33 2014 +0100

tests: thin repair testing

More checks for thin related tools.
Add same functionality for cache related tools.
---
 test/Makefile.in                    |   17 ++++++++
 test/api/thin_percent.sh            |    3 -
 test/lib/aux.sh                     |   59 +++++++++++++++++++-------
 test/shell/lvconvert-repair-thin.sh |   77 +++++++++++++----------------------
 4 files changed, 89 insertions(+), 67 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 9774f6c..1aec88b 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -30,6 +30,11 @@ export LVM_TEST_THIN_DUMP_CMD?=@THIN_DUMP_CMD@
 export LVM_TEST_THIN_REPAIR_CMD?=@THIN_REPAIR_CMD@
 export LVM_TEST_THIN_RESTORE_CMD?=@THIN_RESTORE_CMD@
 
+export LVM_TEST_CACHE_CHECK_CMD?=@CACHE_CHECK_CMD@
+export LVM_TEST_CACHE_DUMP_CMD?=@CACHE_DUMP_CMD@
+export LVM_TEST_CACHE_REPAIR_CMD?=@CACHE_REPAIR_CMD@
+export LVM_TEST_CACHE_RESTORE_CMD?=@CACHE_RESTORE_CMD@
+
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 
@@ -79,6 +84,10 @@ help:
 	@echo "  LVM_TEST_THIN_DUMP_CMD    Command for thin_dump    [$(LVM_TEST_THIN_DUMP_CMD)]."
 	@echo "  LVM_TEST_THIN_REPAIR_CMD  Command for thin_repair  [$(LVM_TEST_THIN_REPAIR_CMD)]."
 	@echo "  LVM_TEST_THIN_RESTORE_CMD Command for thin_restore [$(LVM_TEST_THIN_RESTORE_CMD)]."
+	@echo "  LVM_TEST_CACHE_CHECK_CMD   Command for cache_check   [$(LVM_TEST_CACHE_CHECK_CMD)]."
+	@echo "  LVM_TEST_CACHE_DUMP_CMD    Command for cache_dump    [$(LVM_TEST_CACHE_DUMP_CMD)]."
+	@echo "  LVM_TEST_CACHE_REPAIR_CMD  Command for cache_repair  [$(LVM_TEST_CACHE_REPAIR_CMD)]."
+	@echo "  LVM_TEST_CACHE_RESTORE_CMD Command for cache_restore [$(LVM_TEST_CACHE_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VALGRIND		Enable valgrind testing (1,2,3) execs $$"VALGRIND
 	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
@@ -153,6 +162,14 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
+	echo 'export LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD:- at THIN_CHECK_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD:- at THIN_DUMP_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD:- at THIN_REPAIR_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD:- at THIN_RESTORE_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD:- at CACHE_CHECK_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD:- at CACHE_DUMP_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD:- at CACHE_REPAIR_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD:- at CACHE_RESTORE_CMD@}' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/invalid lib/fail lib/should lib/harness \
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index 5335655..f93bd15 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -15,9 +15,6 @@
 
 aux have_thin 1 0 0 || skip
 
-# disable thin_check if not present in system
-which thin_check || aux lvmconf 'global/thin_check_executable = ""'
-
 aux prepare_devs 2
 
 vgcreate -s 64k $vg $(cat DEVICES)
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8da834c..58b71c6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -767,6 +767,27 @@ can_use_16T() {
 	test "$(getconf LONG_BIT)" -eq 64
 }
 
+# Check if major.minor.revision' string is 'at_least'
+version_at_least() {
+	local major
+	local minor
+	local revision
+	IFS=. read -r major minor revision <<< "$1"
+	shift
+
+	test -z "$1" && return 0
+	test -n "$major" || return 1
+	test "$major" -gt "$1" && return 0
+	test "$major" -eq "$1" || return 1
+
+	test -z "$2" && return 0
+	test -n "$minor" || return 1
+	test "$minor" -gt "$2" && return 0
+	test "$minor" -eq "$2" || return 1
+
+	test -z "$3" && return 0
+	test "$revision" -ge "$3" 2>/dev/null || return 1
+}
 #
 # Check wheter kernel [dm module] target exist
 # at least in expected version
@@ -790,21 +811,7 @@ target_at_least() {
 	version=${version##* v}
 	shift
 
-	local major=$(echo "$version" | cut -d. -f1)
-	test -z "$1" && return 0
-	test -n "$major" || return 1
-	test "$major" -gt "$1" && return 0
-	test "$major" -eq "$1" || return 1
-
-	test -z "$2" && return 0
-	local minor=$(echo "$version" | cut -d. -f2)
-	test -n "$minor" || return 1
-	test "$minor" -gt "$2" && return 0
-	test "$minor" -eq "$2" || return 1
-
-	test -z "$3" && return 0
-	local revision=$(echo "$version" | cut -d. -f3)
-	test "$revision" -ge "$3" 2>/dev/null || return 1
+	version_at_least "$version" "$@"
 }
 
 have_thin() {
@@ -812,7 +819,12 @@ have_thin() {
 	target_at_least dm-thin-pool "$@" || return 1
 
 	# disable thin_check if not present in system
-	which thin_check || lvmconf 'global/thin_check_executable = ""'
+	test -x "$LVM_TEST_THIN_CHECK_CMD" || LVM_TEST_THIN_CHECK_CMD=""
+	test -x "$LVM_TEST_THIN_DUMP_CMD" || LVM_TEST_THIN_DUMP_CMD=""
+	test -x "$LVM_TEST_THIN_REPAIR_CMD" || LVM_TEST_THIN_REPAIR_CMD=""
+	lvmconf "global/thin_check_executable = \"$LVM_TEST_THIN_CHECK_CMD\"" \
+		"global/thin_dump_executable = \"$LVM_TEST_THIN_DUMP_CMD\"" \
+		"global/thin_repair_executable = \"$LVM_TEST_THIN_REPAIR_CMD\""
 }
 
 have_raid() {
@@ -823,6 +835,21 @@ have_raid() {
 have_cache() {
 	test "$CACHE" = shared -o "$CACHE" = internal || return 1
 	target_at_least dm-cache "$@"
+
+	test -x "$LVM_TEST_CACHE_CHECK_CMD" || LVM_TEST_CACHE_CHECK_CMD=""
+	test -x "$LVM_TEST_CACHE_DUMP_CMD" || LVM_TEST_CACHE_DUMP_CMD=""
+	test -x "$LVM_TEST_CACHE_REPAIR_CMD" || LVM_TEST_CACHE_REPAIR_CMD=""
+	lvmconf "global/cache_check_executable = \"$LVM_TEST_CACHE_CHECK_CMD\"" \
+		"global/cache_dump_executable = \"$LVM_TEST_CACHE_DUMP_CMD\"" \
+		"global/cache_repair_executable = \"$LVM_TEST_CACHE_REPAIR_CMD\""
+}
+
+have_tool_at_least() {
+	local version=$($1 -V 2>/dev/null)
+	version=${version%%-*}
+	shift
+
+	version_at_least "$version" "$@"
 }
 
 # check if lvm shell is build-in  (needs readline)
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 6aa5590..4732efc 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,13 +16,6 @@
 
 which mkfs.ext2 || skip
 
-# By default use tools from configuration (exported through Makefile)
-# Allow user to override location of binaries to take tools from different laces
-# Maybe check also version of the tools here?
-test -n "$LVM_TEST_THIN_CHECK_CMD" || LVM_TEST_THIN_CHECK_CMD=$(which thin_check) || skip
-test -n "$LVM_TEST_THIN_DUMP_CMD" || LVM_TEST_THIN_DUMP_CMD=$(which thin_dump) || skip
-test -n "$LVM_TEST_THIN_REPAIR_CMD" || LVM_TEST_THIN_REPAIR_CMD=$(which thin_repair) || skip
-
 #
 # Main
 #
@@ -43,73 +36,61 @@ lvcreate -L2 -n fixed $vg
 lvs -a -o+seg_pe_ranges $vg
 #aux error_dev "$dev2" 2050:1
 
-# Make some repairable metadata damage??
 vgchange -an $vg
 
 lvconvert --repair $vg/pool
 
 lvs -a $vg
 
+# Manual repair steps:
 # Test swapping - swap out thin-pool's metadata with our repair volume
 lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
-lvchange -aey $vg/repair $vg/fixed
+#
+# To continue this test - we need real tools available
+# When they are not present mark test as skipped, but still
+# let proceed initial part which should work even without tools
+#
+aux have_tool_at_least "$LVM_TEST_THIN_CHECK_CMD" 0 3 1 || skip
+aux have_tool_at_least "$LVM_TEST_THIN_DUMP_CMD" 0 3 1 || skip
+aux have_tool_at_least "$LVM_TEST_THIN_REPAIR_CMD" 0 3 1 || skip
 
-#dd if="$DM_DEV_DIR/$vg/repair" of=back bs=1M
+lvchange -aey $vg/repair $vg/fixed
 
 # Make some 'repairable' damage??
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/repair" bs=1 seek=40960 count=1
 
-#dd if="$DM_DEV_DIR/$vg/repair" of=back_trashed bs=1M
-#not vgchange -ay $vg
-
-#lvconvert --repair $vg/pool
-
-# Using now SHOULD - since thin tools currently do not seem to work
-should not "$THIN_CHECK" "$DM_DEV_DIR/$vg/repair"
+not "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/repair"
 
-should not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
+not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 
-should "$LVM_TEST_THIN_REPAIR_CMD" -i "$DM_DEV_DIR/$vg/repair" -o "$DM_DEV_DIR/$vg/fixed"
+"$LVM_TEST_THIN_REPAIR_CMD" -i "$DM_DEV_DIR/$vg/repair" -o "$DM_DEV_DIR/$vg/fixed"
 
-should "$LVM_TEST_THIN_DUMP_CMD" --repair "$DM_DEV_DIR/$vg/repair" | tee repaired_xml
+"$LVM_TEST_THIN_DUMP_CMD" --repair "$DM_DEV_DIR/$vg/repair" | tee repaired_xml
 
-should "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/fixed"
+"$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/fixed"
 
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
 
 # Activate pool - this should now work
-should vgchange -ay $vg
+vgchange -ay $vg
 
-lvs -a -o+devices $vg
-dmsetup table
-dmsetup info -c
-dmsetup ls --tree
-
-lvchange -an $vg
-
-# FIXME: Currently in deep troubles - we can't remove thin volume from broken pool
-should lvremove -ff $vg
+vgchange -an $vg
 
-# let's not block PVs with openned _tdata/_tmeta devices
-aux dmsetup remove $vg-pool_tdata || true
-aux dmsetup remove $vg-pool_tmeta || true
+# Put back 'broken' metadata
+lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
-dmsetup table
+# Check --repair usage
+lvconvert -v --repair $vg/pool
 
-# FIXME: needs  also --yes with double force
-pvremove --yes -ff "$dev1"
-pvremove --yes -ff "$dev2"
+# Check repaired pool could be activated
+lvchange -ay $vg/pool
 
-# FIXME: pv1 & pv2 are removed so pv3 & pv4 have no real LVs,
-# yet vgremove is refusing to do its jobs and suggest --partial??
-should vgremove -ff  $vg
+lvchange -an $vg
 
-# FIXME: stressing even more - there are no pool PV, we do not pass...
-should vgreduce --removemissing -f $vg
-should vgremove -ff  $vg
+# Restore damaged metadata
+lvconvert -y -f --poolmetadata $vg/pool_meta1 --thinpool $vg/pool
 
-# Let's do a final forced cleanup
-pvremove --yes -ff "$dev3"
-pvremove --yes -ff "$dev4"
+# Check lvremove -ff works even with damaged pool
+lvremove -ff $vg


