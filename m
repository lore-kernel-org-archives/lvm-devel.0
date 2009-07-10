From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 21:19:37 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090710211937.30887.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 21:19:37

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Remove unused code vg_lock_and_read() and related flags.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.245&r2=1.246

--- LVM2/lib/metadata/metadata-exported.h	2009/07/10 20:07:02	1.89
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/10 21:19:37	1.90
@@ -96,10 +96,6 @@
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 
-/* LVM2 external library flags */
-#define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
-#define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
-
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
@@ -384,10 +380,6 @@
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
-vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       const char *vgid,
-		       uint32_t lock_flags, uint32_t status_flags,
-		       uint32_t misc_flags);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
 /*
--- LVM2/lib/metadata/metadata.c	2009/07/10 20:09:21	1.245
+++ LVM2/lib/metadata/metadata.c	2009/07/10 21:19:37	1.246
@@ -2732,50 +2732,6 @@
 }
 
 /*
- * vg_lock_and_read - consolidate vg locking, reading, and status flag checking
- *
- * Returns:
- * NULL - failure
- * non-NULL - success; volume group handle
- */
-vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       const char *vgid,
-		       uint32_t lock_flags, uint32_t status_flags,
-		       uint32_t misc_flags)
-{
-	struct volume_group *vg;
-	int consistent = 1;
-
-	if (!(misc_flags & CORRECT_INCONSISTENT))
-		consistent = 0;
-
-	if (!validate_name(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
-			  vg_name);
-		return NULL;
-	}
-
-	if (!lock_vol(cmd, vg_name, lock_flags)) {
-		log_error("Can't get lock for %s", vg_name);
-		return NULL;
-	}
-
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
-	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	if (!vg_check_status(vg, status_flags)) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	return vg;
-}
-
-/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */


