From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:27 +0000 (UTC)
Subject: master - tests: move kernel_at_least to aux
Message-ID: <20150501130827.6858F60366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4daede06e50bc87e7d5e0b9645e239a9fb03adc0
Commit:        4daede06e50bc87e7d5e0b9645e239a9fb03adc0
Parent:        f48a4c391c2f7f92765f6608a60e79b008ead890
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 13:23:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: move kernel_at_least to aux

Hide func processing and reuse existing
version_at_least().
---
 test/api/percent.sh                    |    2 +-
 test/lib/aux.sh                        |    6 +++++-
 test/lib/utils.sh                      |   15 ---------------
 test/shell/lvconvert-repair-replace.sh |    2 +-
 test/shell/lvcreate-usage.sh           |    2 +-
 test/shell/pvcreate-operation-md.sh    |    8 ++++----
 6 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index a503ca3..e099497 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -13,7 +13,7 @@
 
 . lib/inittest
 
-kernel_at_least 2 6 33 || skip
+aux kernel_at_least 2 6 33 || skip
 
 aux prepare_pvs 2
 
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6fceb68..276bb35 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -936,7 +936,7 @@ version_at_least() {
 	local major
 	local minor
 	local revision
-	IFS=. read -r major minor revision <<< "$1"
+	IFS=".-" read -r major minor revision <<< "$1"
 	shift
 
 	test -z "$1" && return 0
@@ -1073,6 +1073,10 @@ total_mem() {
 	done < /proc/meminfo
 }
 
+kernel_at_least() {
+	version_at_least "$(uname -r)" "$@"
+}
+
 test -z "$LVM_TEST_AUX_TRACE" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 80e5922..ba3ba34 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -214,21 +214,6 @@ skip() {
 	exit 200
 }
 
-kernel_at_least() {
-	local major=$(uname -r | cut -d. -f1)
-	local minor=$(uname -r | cut -d. -f2 | cut -d- -f1)
-
-	test "$major" -gt "$1" && return 0
-	test "$major" -eq "$1" || return 1
-	test "$minor" -gt "$2" && return 0
-	test "$minor" -eq "$2" || return 1
-	test -z "$3" && return 0
-
-	local minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
-	test -z "$minor2" -a "$3" -ne 0 && return 1
-	test "$minor2" -ge "$3" 2>/dev/null || return 1
-}
-
 get_devs() {
 	local IFS=$IFS_NL
 	DEVICES=( $(<DEVICES) )
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 8a3567c..bf031be 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -67,7 +67,7 @@ check mirror $vg mirror2
 vgs $vg
 vgremove -ff $vg
 
-if kernel_at_least 3 0 0; then
+if aux kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace
 	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index fe82005..45fa850 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -175,7 +175,7 @@ fail lvcreate -Mn --major 234 -l1 $vg
 fail lvcreate --persistent n --minor 234 -l1 $vg
 # out-of-range minor value
 fail lvcreate --minor 9999999 -l1 $vg
-if kernel_at_least 2 4 0; then
+if aux kernel_at_least 2 4 0; then
 # On >2.4 we ignore --major
 lvcreate --major 234 -l1 $vg |& tee err;
 grep "Ignoring" err
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 810fc53..52a2c37 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -45,7 +45,7 @@ check pv_field "$pvdev" pe_start "1.00m"
 
 # Test newer topology-aware alignment detection
 # - first added to 2.6.31 but not "reliable" until 2.6.33
-if kernel_at_least 2 6 33 ; then
+if aux kernel_at_least 2 6 33 ; then
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
@@ -53,7 +53,7 @@ if kernel_at_least 2 6 33 ; then
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
-if kernel_at_least 2 6 28 ; then
+if aux kernel_at_least 2 6 28 ; then
     # create one partition
     sfdisk "$mddev" <<EOF
 ,,83
@@ -69,7 +69,7 @@ EOF
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
-    if kernel_at_least 2 6 33 ; then
+    if aux kernel_at_least 2 6 33 ; then
 	# in case the system is running without devtmpfs /dev
 	# wait here for created device node on tmpfs
 	test "$DM_DEV_DIR" != "/dev" && cp -LR "${mddev}p1" "$DM_DEV_DIR"
@@ -94,7 +94,7 @@ EOF
 fi
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
-if kernel_at_least 2 6 33 ; then
+if aux kernel_at_least 2 6 33 ; then
     # make sure we're clean for another test
     dd if=/dev/zero of="$mddev" bs=512 count=1
     aux prepare_md_dev 0 1024 2 "$dev1" "$dev2"


