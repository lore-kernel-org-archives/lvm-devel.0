From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:59 +0200
Subject: [PATCH 7/9] Remove now-unused vg_lock_and_read.
In-Reply-To: <1241350741-31349-7-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
	<1241350741-31349-5-git-send-email-prockai@redhat.com>
	<1241350741-31349-6-git-send-email-prockai@redhat.com>
	<1241350741-31349-7-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-8-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:14:51 CEST 2009  Petr Rockai <me@mornfall.net>
  * Remove now-unused vg_lock_and_read.
diff -rN -u -p old-temp.31080/lib/metadata/metadata.c new-temp.31080/lib/metadata/metadata.c
--- old-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:37.630236334 +0200
+++ new-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:37.682236658 +0200
@@ -2541,50 +2541,6 @@ int vg_check_status(const struct volume_
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
-		unlock_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	if (!vg_check_status(vg, status_flags)) {
-		unlock_release_vg(cmd, vg, vg_name);
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
diff -rN -u -p old-temp.31080/lib/metadata/metadata-exported.h new-temp.31080/lib/metadata/metadata-exported.h
--- old-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:37.630236334 +0200
+++ new-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:37.682236658 +0200
@@ -96,10 +96,6 @@ struct pv_segment;
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 
-/* LVM2 external library flags */
-#define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
-#define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
-
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */


