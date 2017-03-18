From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 18 Mar 2017 16:23:05 -0400
Subject: master - tests: early detect leaking error dev
Message-ID: <201703182023.v2IKN5ef015807@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a7590e31e6008dde6c226ec14b97adcb5331299
Commit:        3a7590e31e6008dde6c226ec14b97adcb5331299
Parent:        07040942ed02455cf168ba6cf40264a644627553
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 18 19:39:48 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 18 19:42:36 2017 +0100

tests: early detect leaking error dev

lvconvert should not leak 'error' device.

(This patch is not fix the problem, just makes it more easily visible
instead of more confusing 'clvmd' trace).
---
 D/test/shell/pvmove-background.sh     |    1 +
 test/shell/lvconvert-raid-takeover.sh |   28 +++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/D/test/shell/pvmove-background.sh b/D/test/shell/pvmove-background.sh
new file mode 120000
index 0000000..479c5b0
--- /dev/null
+++ b/D/test/shell/pvmove-background.sh
@@ -0,0 +1 @@
+/home/kabi/export/lvm2/test/shell/pvmove-background.sh
\ No newline at end of file
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 0e8e880..e1b1d98 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -22,6 +22,26 @@ aux have_raid 1 9 1 && correct_raid4_layout=1
 
 aux prepare_vg 8
 
+# FIXME: lvconvert leaks  'error' devices
+detect_error_leak_()
+{
+	local err
+
+	dmsetup info -c -o name --noheadings | tee out
+	if grep $vg out ; then
+		for i in $(grep $vg out) ; do
+			if dmsetup table $i | grep "error "; then
+				err="$err $i"
+			fi
+		done
+		test -z "$err" || {
+			dmsetup table | grep $vg
+			dmsetup ls --tree
+			die "Device(s) $err should not be here."
+		}
+	fi
+}
+
 function _lvcreate
 {
 	local level=$1
@@ -56,7 +76,8 @@ function _lvconvert
 	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
 
 	lvconvert -y --ty $req_level $R $vg/$lv
-	[ $? -ne 0 ] && return $?
+	detect_error_leak_
+
 	check lv_field $vg/$lv segtype "$level"
 	check lv_field $vg/$lv data_stripes $data_stripes
 	check lv_field $vg/$lv stripes $stripes
@@ -112,6 +133,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 3-way to 4-way mirror
 lvconvert -m 3 $vg/$lv1
+detect_error_leak_
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 4
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
@@ -120,6 +142,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Takeover 4-way mirror to raid1
 lvconvert --yes --type raid1 -R 64k $vg/$lv1
+detect_error_leak_
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 regionsize "64.00k"
@@ -127,6 +150,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 ## Convert 4-way raid1 to 5-way
 lvconvert -m 4 -R 128K $vg/$lv1
+detect_error_leak_
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 5
 check lv_field $vg/$lv1 regionsize "128.00k"
@@ -142,6 +166,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 5-way raid1 to 2-way
 lvconvert --yes -m 1 $vg/$lv1
+detect_error_leak_
 lvs $vg/$lv1
 dmsetup status $vg-$lv1
 dmsetup table $vg-$lv1
@@ -151,6 +176,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 2-way raid1 to mirror
 lvconvert --yes --type mirror -R 32K $vg/$lv1
+detect_error_leak_
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 2
 check lv_field $vg/$lv1 regionsize "32.00k"


