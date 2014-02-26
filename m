From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Feb 2014 12:26:33 +0000 (UTC)
Subject: master - lvresize: fix stripe size validation
Message-ID: <20140226122633.8B63461128@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=014ba37cb19c9172b1b81af3f31897939f72b1d2
Commit:        014ba37cb19c9172b1b81af3f31897939f72b1d2
Parent:        b5e03c88b8b31db9a4b27c2e1a50441f99e0da48
Author:        Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>
AuthorDate:    Wed Feb 26 10:14:18 2014 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 13:25:50 2014 +0100

lvresize: fix stripe size validation

While stripe size is twice the physical extent size,
the original code will not reduce stripe size to maximum
(physical extent size).

Signed-off-by: Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>
---
 WHATS_NEW                    |    1 +
 lib/metadata/lv_manip.c      |   11 ++++++-----
 man/lvresize.8.in            |    4 +++-
 test/shell/lvresize-usage.sh |    9 +++++++--
 4 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 05218ee..9a3da75 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Do not allow stripe size to be bigger then extent size for lvresize.
   Zero snapshot COW header when creating read-only snapshot.
   Comment out config lines in dumpconfig output without default values defined.
   Improve detection of clustered mirror support.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9dd8f0e..57ce2d9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3406,6 +3406,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 
 #define SIZE_BUF 128
 
+/* TODO: unify stripe size validation across source code */
 static int _validate_stripesize(struct cmd_context *cmd,
 				const struct volume_group *vg,
 				struct lvresize_params *lp)
@@ -3419,11 +3420,11 @@ static int _validate_stripesize(struct cmd_context *cmd,
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (lp->ac_stripesize_value > (uint64_t) vg->extent_size * 2) {
-		log_error("Reducing stripe size %s to maximum, "
-			  "physical extent size %s",
-			  display_size(cmd,lp->ac_stripesize_value),
-			  display_size(cmd, (uint64_t) vg->extent_size));
+	else if (lp->ac_stripesize_value > vg->extent_size) {
+		log_print_unless_silent("Reducing stripe size %s to maximum, "
+					"physical extent size %s",
+					display_size(cmd, lp->ac_stripesize_value),
+					display_size(cmd, vg->extent_size));
 		lp->stripe_size = vg->extent_size;
 	} else
 		lp->stripe_size = lp->ac_stripesize_value;
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 14fc7ba..75d20a0 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -95,7 +95,9 @@ Defaults to whatever the last segment of the Logical Volume uses.
 Not applicable to LVs using the original metadata LVM format, which
 must use a single value throughout.
 .br
-StripeSize must be 2^n (n = 2 to 9).
+StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
+For metadata in LVM2 format, the stripe size may be a larger
+power of 2 but must not exceed the physical extent size.
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 51ef221..84431ed 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux prepare_vg 2
+aux prepare_vg 2 80
 
 lvcreate -L 10M -n lv -i2 $vg
 lvresize -l +4 $vg/lv
@@ -19,3 +19,8 @@ lvremove -ff $vg
 
 lvcreate -L 64M -n $lv -i2 $vg
 not lvresize -v -l +4 xxx/$lv
+
+# Check stripe size is reduced to extent size when it's bigger
+ESIZE=$(get vg_field $vg vg_extent_size --units b)
+lvextend -L+64m -i 2 -I$(( ${ESIZE%%B} * 2 ))B $vg/$lv 2>&1 | tee err
+grep "Reducing stripe size" err


