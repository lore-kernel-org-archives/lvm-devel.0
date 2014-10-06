From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:30 +0000 (UTC)
Subject: master - vg/lvremove: support --yes
Message-ID: <20141006133330.1CBF8610D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79ca382b2c24fd01aa25c98c0ab29b97a4358270
Commit:        79ca382b2c24fd01aa25c98c0ab29b97a4358270
Parent:        fbf14b12d8710f10b7a7f1a0a23347ac5ad1a826
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 4 17:05:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:22:24 2014 +0200

vg/lvremove: support --yes

Make --yes equivalent to DONT_PROMT (--force).

So user could use 'lvremove --yes vg/lvol1' skipping prompt.
---
 WHATS_NEW        |    1 +
 tools/lvremove.c |   12 ++++++++++--
 tools/vgremove.c |   11 ++++++++---
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d2b5303..3855bb1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Support --yes like --force in vg/lvremove to skip y|n prompt.
   Support --yes with lvconvert --splitsnapshot.
   Fix detection of unsupported thin external lvconversions.
   Fix detection of unsupported cache and thin pool lvconversions.
diff --git a/tools/lvremove.c b/tools/lvremove.c
index dfc435c..7d2fec1 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,7 +18,15 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
-	if (!lv_remove_with_dependencies(cmd, lv, (force_t) arg_count(cmd, force_ARG), 0))
+	/*
+	 * Single force is equivalent to sinle --yes
+	 * Even multiple --yes are equivalent to single --force
+	 * When we require -ff it cannot be replaces with -f -y
+	 */
+	force_t force = (force_t) arg_count(cmd, force_ARG)
+		? : (arg_is_set(cmd, yes_ARG) ? DONT_PROMPT : PROMPT);
+
+	if (!lv_remove_with_dependencies(cmd, lv, force, 0))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 52bdd2b..0bbca76 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,15 +19,20 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
+	/*
+	 * Single force is equivalent to sinle --yes
+	 * Even multiple --yes are equivalent to single --force
+	 * When we require -ff it cannot be replaces with -f -y
+	 */
+	force_t force = (force_t) arg_count(cmd, force_ARG)
+		? : (arg_is_set(cmd, yes_ARG) ? DONT_PROMPT : PROMPT);
 	unsigned lv_count, missing;
-	force_t force;
 
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return_ECMD_FAILED;
 
 	lv_count = vg_visible_lvs(vg);
 
-	force = (force_t) arg_count(cmd, force_ARG);
 	if (lv_count) {
 		if (force == PROMPT) {
 			if ((missing = vg_missing_pv_count(vg)))


