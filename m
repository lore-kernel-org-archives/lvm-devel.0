From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:09 +0100
Subject: [PATCH 13/14] Remove now-unused vg_lock_and_read.
In-Reply-To: <1232619010-4858-13-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
	<1232619010-4858-7-git-send-email-prockai@redhat.com>
	<1232619010-4858-8-git-send-email-prockai@redhat.com>
	<1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232619010-4858-10-git-send-email-prockai@redhat.com>
	<1232619010-4858-11-git-send-email-prockai@redhat.com>
	<1232619010-4858-12-git-send-email-prockai@redhat.com>
	<1232619010-4858-13-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-14-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 10:52:08 CET 2009  Petr Rockai <me@mornfall.net>
  * Remove now-unused vg_lock_and_read.
diff -rN -u -p old-temp.4430/lib/metadata/metadata.c new-temp.4430/lib/metadata/metadata.c
--- old-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:56.842777680 +0100
+++ new-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:56.890780708 +0100
@@ -2424,50 +2424,6 @@ int vg_check_status(const struct volume_
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
-		unlock_vg(cmd, vg_name);
-		return NULL;
-	}
-
-	if (!vg_check_status(vg, status_flags)) {
-		unlock_vg(cmd, vg_name);
-		return NULL;
-	}
-
-	return vg;
-}
-
-/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code. Zero failure code = success.
  */
diff -rN -u -p old-temp.4430/lib/metadata/metadata-exported.h new-temp.4430/lib/metadata/metadata-exported.h
--- old-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:56.842777680 +0100
+++ new-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:56.890780708 +0100
@@ -95,10 +95,6 @@ struct pv_segment;
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 
-/* LVM2 external library flags */
-#define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
-#define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
-
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */


