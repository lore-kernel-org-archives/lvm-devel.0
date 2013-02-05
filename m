From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:49 +0000 (UTC)
Subject: master - thin: fix forbidden discards checks
Message-ID: <20130205134749.5ECB7A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5b9b4bf02b42baf1f1c033eaa98c5fe23951b43
Commit:        a5b9b4bf02b42baf1f1c033eaa98c5fe23951b43
Parent:        11eaf1c98c3fac8524f227956f57c3d486740a1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 2 12:48:52 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:38:16 2013 +0100

thin: fix forbidden discards checks

Instead of check for lv_is_active() for thin pool LV,
query the whole pool via new  pool_is_active().

Fixes a problem when we cannot change discards settings
for active pool device where the actual layer for pool
device was inactive, but thin volumes using thin pool
have been active.
---
 WHATS_NEW                   |    1 +
 test/shell/discards-thin.sh |   22 ++++++++++++++++++----
 tools/lvchange.c            |    4 ++--
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1b26317..b6c1785 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix check for some forbidden discards conversion of thin pools.
   Add pool_is_active() to check for any pool related active LV.
   Report blank field if the LV doesn't have an origin instead of 0.
   Do not take a free lv name argument for lvconvert --thinpool option.
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 84688b4..525f106 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -34,16 +34,30 @@ check lv_field $vg/pool2 discards "passdown"
 
 lvchange --discards nopassdown $vg/pool2
 
-# cannot convert active  ignore -> passdown
+lvcreate -V1M -n origin -T $vg/pool
+lvcreate -s $vg/origin -n snap
+
+# Cannot convert active  nopassdown -> ignore
+not lvchange --discards nopassdown $vg/pool
+
+# Cannot convert active  ignore -> passdown
 not lvchange --discards passdown $vg/pool
 
-# cannot convert active  nopassdown -> ignore
+# Cannot convert active  nopassdown -> ignore
 not lvchange --discards ignore $vg/pool1
 
-# deactivate
+# Deactivate pool only
 lvchange -an $vg/pool $vg/pool1
+
+# Cannot convert, since thin volumes are still active
+not lvchange --discards passdown $vg/pool
+
+# Deactive thin volumes
+lvchange -an $vg/origin $vg/snap
+
 lvchange --discards passdown $vg/pool
 check lv_field $vg/pool discards "passdown"
+
 lvchange --discards ignore $vg/pool1
 check lv_field $vg/pool1 discards "ignore"
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c3c993a..0ea2e78 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -113,9 +113,9 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 		if (discards != first_seg(lv)->discards) {
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
-			    lv_is_active(lv))
+			    pool_is_active(first_seg(lv)))
 				log_error("Cannot change discards state for active "
-					  "logical volume \"%s\".", lv->name);
+					  "pool volume \"%s\".", lv->name);
 			else {
 				first_seg(lv)->discards = discards;
 				update++;


