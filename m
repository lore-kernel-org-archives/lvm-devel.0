From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Oct 2012 13:37:40 +0000 (UTC)
Subject: master - pvcreate: fix leak on error path
Message-ID: <20121019133740.5C5B4A1046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7c53ad41d5521d5b431e799699c9ad6a07054a4
Commit:        c7c53ad41d5521d5b431e799699c9ad6a07054a4
Parent:        0e47639a44e1630250ea10643f5a440281edfdce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 18 14:32:56 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 19 15:32:21 2012 +0200

pvcreate: fix leak on error path

Missing vg release on error path.
Add tests for few more error cases.
---
 WHATS_NEW                        |    1 +
 test/shell/pvcreate-operation.sh |   11 ++++++++++-
 tools/pvcreate.c                 |    1 +
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ba9f2d..ad0756a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix memory leak on error path for pvcreate with invalid uuid.
   Use lv_is_active() instead of lv_info() call.
   Cleanup some log_error message and use log_warn instead.
   
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index 55fff4e..ddcf94c 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -1,4 +1,4 @@
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -121,6 +121,15 @@ vgcfgrestore -f $backupfile $vg1
 vgremove -f $vg1
 pvremove -f $dev1
 
+# pvcreate rejects non-existent uuid given with restorefile
+not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
+
+# pvcreate rejects restorefile without uuid
+not pvcreate --restorefile $backupfile "$dev1"
+
+# pvcreate rejects uuid restore with multiple volumes specified
+not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1" "$dev2"
+
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of="$dev1" bs=1024 count=64
 mkswap "$dev1"
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 5c12acb..c75f561 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -68,6 +68,7 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 			return 0;
 		}
 		if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, pp->idp))) {
+			release_vg(vg);
 			log_error("Can't find uuid %s in backup file %s",
 				  uuid, pp->restorefile);
 			return 0;


