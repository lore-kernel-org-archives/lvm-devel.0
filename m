From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 May 2009 18:21:10 -0400
Subject: [PATCH] Remove LOCK_NONBLOCKING from new vg_read() interface.
In-Reply-To: <1242166871-25734-1-git-send-email-dwysocha@redhat.com>
References: <1242166871-25734-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1242166871-25734-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch simplifies the vg_read() interface by removing a flag,
LOCK_NONBLOCKING.  We can remove the flag if we set the following
policy:
- The first vg lock taken is taken non-blocking (w/out LCK_NONBLOCK)
- Any subsequent locks taken after the first are non-blocking.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    9 +++++++--
 tools/vgextend.c                 |    2 +-
 tools/vgmerge.c                  |    3 +--
 tools/vgreduce.c                 |    2 +-
 tools/vgremove.c                 |    2 +-
 tools/vgrename.c                 |    2 +-
 tools/vgsplit.c                  |    2 +-
 8 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1523c79..8116f16 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -108,7 +108,6 @@ struct pv_segment;
 #define READ_CHECK_EXISTENCE	0x00080000U	/* Also used in vg->read_status */
 
 /* FIXME Deduce these next requirements internally instead of having caller specify. */
-#define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
 #define LOCK_KEEP		0x00000200U	/* Do not unlock upon read failure. */
 
 /* A meta-flag, useful with toollib for_each_* functions. */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff37fba..7b4c512 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2737,7 +2737,12 @@ vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
 	if (flags & READ_REQUIRE_RESIZEABLE)
 		status |= RESIZEABLE_VG;
 
-	if (flags & LOCK_NONBLOCKING)
+	/*
+	 * Automatically set LCK_NONBLOCK if one or more VGs locked.
+	 * This will enforce correctness and prevent deadlocks rather
+	 * than relying on the caller to set the flag properly.
+	 */
+	if (vgs_locked())
 		lock_flags |= LCK_NONBLOCK;
 
 	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
diff --git a/tools/vgextend.c b/tools/vgextend.c
index d589005..db611e8 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -43,7 +43,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
  	vg = vg_read_for_update(cmd, vg_name, NULL,
- 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+				READ_REQUIRE_RESIZEABLE);
  	if (vg_read_error(vg)) {
  		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index adba52e..292cf82 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -33,8 +33,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
- 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
- 				     LOCK_NONBLOCKING);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
  	if (vg_read_error(vg_from)) {
 		unlock_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 749b45e..8ffa05f 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -419,7 +419,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->extent_count -= pv_pe_count(pv);
 
  	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
- 				       NULL, LOCK_NONBLOCKING);
+				       NULL, 0);
 
  	if (vg_read_error(orphan_vg))
 		goto bad;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 1d0849d..3363a1e 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -41,7 +41,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      READ_FOR_UPDATE | LOCK_NONBLOCKING,
+			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 447b808..ea9c17e 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -86,7 +86,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
 	vg_new = vg_read_for_update(cmd, vg_name_new, NULL, LOCK_KEEP |
-				    READ_CHECK_EXISTENCE | LOCK_NONBLOCKING);
+				    READ_CHECK_EXISTENCE);
 
 	if (vg_read_error(vg_new))
 		goto error;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index b96babd..0334d7a 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -329,7 +329,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 				   READ_REQUIRE_RESIZEABLE |
-				   LOCK_NONBLOCKING | LOCK_KEEP |
+				   LOCK_KEEP |
 				   READ_CHECK_EXISTENCE);
 
 	if (vg_read_error(vg_to))
-- 
1.6.0.6


