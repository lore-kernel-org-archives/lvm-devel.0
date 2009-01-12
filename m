From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:08:06 +0100
Subject: [PATCH 11/11] Remove now-unused vg_lock_and_read.
In-Reply-To: <1231769286-15534-11-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
	<1231769286-15534-5-git-send-email-prockai@redhat.com>
	<1231769286-15534-6-git-send-email-prockai@redhat.com>
	<1231769286-15534-7-git-send-email-prockai@redhat.com>
	<1231769286-15534-8-git-send-email-prockai@redhat.com>
	<1231769286-15534-9-git-send-email-prockai@redhat.com>
	<1231769286-15534-10-git-send-email-prockai@redhat.com>
	<1231769286-15534-11-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-12-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 15:48:51 CET 2009  Petr Rockai <me@mornfall.net>
  * Remove now-unused vg_lock_and_read.
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:56:03.159015547 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:56:03.219017936 +0100
@@ -2422,50 +2422,6 @@ int vg_check_status(const struct volume_
 	return !_vg_check_status(vg, status);
 }
 
-/*
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
 static vg_t *_vg_make_handle(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     uint32_t failure)


