From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Apr 2015 11:38:24 +0000 (UTC)
Subject: master - blkdeactivate: check for lvm binary and skip LVM processing if not present
Message-ID: <20150414113824.7939160A57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a4e27eee51e89a550bc55f78daea6d943293202
Commit:        7a4e27eee51e89a550bc55f78daea6d943293202
Parent:        d1a770107d9525c24fc17522be450e28e1463e45
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 14 13:35:11 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 14 13:35:11 2015 +0200

blkdeactivate: check for lvm binary and skip LVM processing if not present

This removes dependency on lvm binary - if it's not present, all LVM
processing is skipped (shouldn't normally happen because if lvm binary
is missing then there's obviously nothing that would activate it, but
let's make sure).

Without this tight dependency on lvm, the blkdeactivate script can
be packaged with libdevmapper/dmsetup (in contrast to lvm as it was
before) and as such the script can still be used to handle other DM
devices.
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |   24 +++++++++++++++++++++---
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e496fe4..9313ffb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Check for lvm binary in blkdeactivate and skip LVM processing if not present.
   Add --enable-halvm and --disable-halvm options to lvmconf script.
   Add --services, --mirrorservice and --startstopservices option to lvmconf.
   Use proper default value of global/use_lvmetad when processing lvmconf script.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index f454154..993f151 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -18,8 +18,10 @@
 #
 # Requires:
 #   bash >= 4.0 (associative array support)
-#   lsblk >= 2.22 (lsblk -s support)
-#   umount
+#   util-linux {
+#       lsblk >= 2.22 (lsblk -s support)
+#       umount
+#   }
 #   dmsetup >= 1.02.68 (--retry option support)
 #   lvm >= 2.2.89 (activation/retry_deactivation config support)
 #
@@ -212,6 +214,11 @@ deactivate_lvm () {
 	test -z ${SKIP_VG_LIST["$DM_VG_NAME"]} || return 1
 
 	if test $LVM_DO_WHOLE_VG -eq 0; then
+		# Skip LVM device deactivation if LVM tools missing.
+		test $LVM_AVAILABLE -eq 0 && {
+			add_device_to_skip_list
+			return 1
+		}
 		# Deactivating only the LV specified
 		deactivate_holders "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || {
 			add_device_to_skip_list
@@ -227,6 +234,11 @@ deactivate_lvm () {
 		fi
 
 	else
+		# Skip LVM VG deactivation if LVM tools missing.
+		test $LVM_AVAILABLE -eq 0 && {
+			add_vg_to_skip_list
+			return 1
+		}
 		# Deactivating the whole VG the LV is part of
 		lv_list=$(eval $LVM vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name $DM_VG_NAME $ERR)
 		for lv in $lv_list; do
@@ -383,6 +395,12 @@ set_env() {
 	else
 		OUT="1>$DEV_DIR/null"
 	fi
+
+	if test -f $LVM; then
+		LVM_AVAILABLE=1
+	else
+		LVM_AVAILABLE=0
+	fi
 }
 
 while test $# -ne 0; do


