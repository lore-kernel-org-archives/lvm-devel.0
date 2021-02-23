From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 Feb 2021 22:48:50 +0000 (GMT)
Subject: main - tests: allow tests to use real devices
Message-ID: <20210223224850.A60FE3893674@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=135c226e26e966faf73f5257c17d45276e5a6b6c
Commit:        135c226e26e966faf73f5257c17d45276e5a6b6c
Parent:        83fe6e720f42711ff183a66909b690b726702f58
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 16:05:39 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 16:43:37 2021 -0600

tests: allow tests to use real devices

user creates a file listing real devices they want
lvm tests to use, and sets LVM_TEST_DEVICE_LIST.
lvm tests can use these with prepare_real_devs
and get_real_devs.
Other aux functions do not work with these devs.
---
 test/Makefile.in        |  1 +
 test/lib/aux.sh         | 19 ++++++++++++++++++-
 test/lib/utils.sh       | 18 +++++++++++++++++-
 test/shell/real_devs.sh | 39 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bbdde7196..882620362 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -109,6 +109,7 @@ help:
 	@echo "  LVM_TEST_CACHE_REPAIR_CMD  Command for cache_repair  [$(LVM_TEST_CACHE_REPAIR_CMD)]."
 	@echo "  LVM_TEST_CACHE_RESTORE_CMD Command for cache_restore [$(LVM_TEST_CACHE_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
+	@echo "  LVM_TEST_DEVICE_LIST   File path listing real devs that tests can use."
 	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMPOLLD	Enable valgrind testing of lvmpolld (1)."
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 31741ac74..72837de22 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -657,6 +657,24 @@ prepare_ramdisk() {
 	touch RAMDISK
 }
 
+prepare_real_devs() {
+	aux lvmconf 'devices/scan = "/dev"'
+
+	touch REAL_DEVICES
+
+	if test -n "$LVM_TEST_DEVICE_LIST"; then
+		local count=0
+		while read path; do
+			REAL_DEVICES[$count]=$path
+			count=$((  count + 1 ))
+			aux extend_filter "a|$path|"
+			dd if=/dev/zero of="$path" bs=32k count=1
+			wipefs -a "$path" 2>/dev/null || true
+		done < $LVM_TEST_DEVICE_LIST
+	fi
+	printf "%s\\n" "${REAL_DEVICES[@]}" > REAL_DEVICES
+}
+
 # A drop-in replacement for prepare_loop() that uses scsi_debug to create
 # a ramdisk-based SCSI device upon which all LVM devices will be created
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
@@ -909,7 +927,6 @@ prepare_devs() {
 	echo "ok"
 }
 
-
 common_dev_() {
 	local tgtype=$1
 	local dev=$2
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 88de1a0e2..175d1564a 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -252,6 +252,11 @@ skip() {
 	exit 200
 }
 
+get_real_devs() {
+	REAL_DEVICES=( $(<REAL_DEVICES) )
+	export REAL_DEVICES
+}
+
 get_devs() {
 	local IFS=$IFS_NL
 	DEVICES=( $(<DEVICES) )
@@ -265,10 +270,21 @@ prepare_test_vars() {
 	lv=LV
 
 	for i in {1..16}; do
-		eval "dev$i=\"$DM_DEV_DIR/mapper/${PREFIX}pv$i\""
 		eval "lv$i=\"LV$i\""
 		eval "vg$i=\"${PREFIX}vg$i\""
 	done
+
+	if test -n "$LVM_TEST_DEVICE_LIST"; then
+		local count=0
+		while read path; do
+			count=$((  count + 1 ))
+			eval "dev$count=\"$path\""
+		done < $LVM_TEST_DEVICE_LIST
+	else
+		for i in {1..16}; do
+			eval "dev$i=\"$DM_DEV_DIR/mapper/${PREFIX}pv$i\""
+		done
+	fi
 }
 
 if test -z "${abs_top_builddir+varset}" && test -z "${installed_testsuite+varset}"; then
diff --git a/test/shell/real_devs.sh b/test/shell/real_devs.sh
new file mode 100644
index 000000000..a1a49c8bb
--- /dev/null
+++ b/test/shell/real_devs.sh
@@ -0,0 +1,39 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='hello world for user-defined device list'
+
+. lib/inittest
+
+aux prepare_real_devs
+
+echo "$dev1"
+
+pvcreate "$dev1"
+
+pvs "$dev1"
+
+pvremove "$dev1"
+
+vgcreate $vg "$dev1"
+
+lvcreate -l1 $vg
+
+vgchange -an $vg
+
+vgremove -ff $vg
+
+get_real_devs
+for d in "${REAL_DEVICES[@]}"; do
+	echo $d
+done
+


