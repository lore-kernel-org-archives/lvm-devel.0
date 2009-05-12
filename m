From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 May 2009 18:21:11 -0400
Subject: [PATCH] Remove NON_BLOCKING flag from the tools and set a policy to auto-set.
In-Reply-To: <1242166871-25734-2-git-send-email-dwysocha@redhat.com>
References: <1242166871-25734-1-git-send-email-dwysocha@redhat.com>
	<1242166871-25734-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1242166871-25734-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As a simplification to the tools and further liblvm, this patch pushes
the setting of NON_BLOCKING lock flag inside the lock_vol() call.
The policy we set is if any existing VGs are currently locked, we
set the NON_BLOCKING flag.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/locking/locking.c |    8 ++++++++
 tools/vgcfgrestore.c  |    4 ++--
 tools/vgcreate.c      |    4 ++--
 tools/vgextend.c      |    4 ++--
 tools/vgmerge.c       |    4 ++--
 tools/vgreduce.c      |    2 +-
 tools/vgremove.c      |    4 ++--
 tools/vgrename.c      |    2 +-
 tools/vgsplit.c       |    2 +-
 9 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index ad93ddd..37136ee 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -376,6 +376,14 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		/*
+		 * Automatically set LCK_NONBLOCK if one or more VGs locked.
+		 * This will enforce correctness and prevent deadlocks rather
+		 * than relying on the caller to set the flag properly.
+		 */
+		if (vgs_locked())
+			flags |= LCK_NONBLOCK;
+
 		/* Lock VG to change on-disk metadata. */
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 3c66b62..6ec20d1 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -48,7 +48,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index add394a..0b8b769 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -51,7 +51,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 5d99cce..280017f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -42,7 +42,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE | LCK_NONBLOCK,
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG |
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index c847c7e..9a276d6 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -35,7 +35,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
-					 LCK_VG_WRITE | LCK_NONBLOCK,
+					 LCK_VG_WRITE,
 					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
 					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		unlock_release_vg(cmd, vg_to, vg_name_to);
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 8d40793..cf55afe 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -397,7 +397,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 8c4357e..38f9ee3 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -41,7 +41,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      LCK_VG_WRITE | LCK_NONBLOCK, 1,
+			      LCK_VG_WRITE, 1,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 697d27b..205ba3e 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -100,7 +100,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE)) {
 		unlock_release_vg(cmd, vg, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 87e74a4..2b30871 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -328,7 +328,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vg_name_to);
 		unlock_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
-- 
1.6.0.6


