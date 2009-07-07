From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 00:24:23 -0400
Subject: [PATCH] Remove READ_CHECK_EXISTENCE and vg_might_exist().
In-Reply-To: <1246940664-14890-3-git-send-email-dwysocha@redhat.com>
References: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-2-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1246940664-14890-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove READ_CHECK_EXISTENCE and vg_might_exist().
This flag and API is no longer used now that we have a separate
API to check for existence.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 -
 lib/metadata/metadata.c          |   47 +------------------------------------
 2 files changed, 2 insertions(+), 47 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6e45698..33eeae0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -109,7 +109,6 @@ struct pv_segment;
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_REQUIRE_RESIZEABLE	0x00040000U
-#define READ_CHECK_EXISTENCE	0x00080000U	/* Also used in vg->read_status */
 
 /* FIXME Deduce these next requirements internally instead of having caller specify. */
 #define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
@@ -406,7 +405,6 @@ vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
  * Test validity of a VG handle.
  */
 uint32_t vg_read_error(vg_t *vg_handle);
-uint32_t vg_might_exist(vg_t *vg_handle);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3c25847..25c2795 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2754,9 +2754,6 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	if (is_orphan_vg(vg_name))
 		status_flags &= ~LVM_WRITE;
 
-	if (misc_flags & READ_CHECK_EXISTENCE)
-		consistent = 0;
-
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
@@ -2767,10 +2764,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			goto_bad;
 		}
 
-		if (!(misc_flags & READ_CHECK_EXISTENCE))
-			log_error("Volume group \"%s\" not found", vg_name);
-		else
-			failure |= READ_CHECK_EXISTENCE;
+		log_error("Volume group \"%s\" not found", vg_name);
 
 		failure |= FAILED_NOTFOUND;
 		goto_bad;
@@ -2801,8 +2795,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	return _vg_make_handle(cmd, vg, failure);
 
 bad:
-	if (failure != (FAILED_NOTFOUND | READ_CHECK_EXISTENCE) &&
-	    !already_locked)
+	if (!already_locked)
 		unlock_vg(cmd, lock_name);
 
 	return _vg_make_handle(cmd, vg, failure);
@@ -2821,7 +2814,6 @@ bad:
  *  - locking failed: FAILED_LOCKING
  *
  * On failures, all locks are released, unless one of the following applies:
- *  - failure == (FAILED_NOTFOUND | READ_CHECK_EXISTENCE)
  *  - vgname_is_locked(lock_name) is true
  * FIXME: remove the above 2 conditions if possible and make an error always
  * release the lock.
@@ -2830,12 +2822,6 @@ bad:
  *
  * Checking for VG existence:
  *
- * If READ_CHECK_EXISTENCE is set in flags, if the VG exists, a non-NULL struct
- * volume_group will be returned every time, but if it has INCONSISTENT_VG set,
- * the other fields will be uninitialized.  You must check for INCONSISTENT_VG
- * if passing READ_CHECK_EXISTENCE.  You also must not use it if it has
- * INCONSISTENT_VG set.
- *
  * FIXME: We want vg_read to attempt automatic recovery after acquiring a
  * temporary write lock: if that fails, we bail out as usual, with failed &
  * FAILED_INCONSISTENT. If it works, we are good to go. Code that's been in
@@ -2878,45 +2864,16 @@ vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
- *
- * If READ_CHECK_EXISTENCE was supplied the non-existence of the volume group
- * is not considered an error.
- *
- * !vg_read_error() && vg_might_exist() => valid handle to VG.
- * vg_read_error() && vg_might_exist() => handle invalid, but VG might
- *					  exist but cannot be read.
- * !vg_read_error() && !vg_might_exist() => the VG does not exist
- * vg_read_error() && !vg_might_exist() is impossible.
  */
 uint32_t vg_read_error(vg_t *vg_handle)
 {
 	if (!vg_handle)
 		return FAILED_ALLOCATION;
 
-	if (vg_handle->read_status & READ_CHECK_EXISTENCE)
-		return vg_handle->read_status &
-		       ~(READ_CHECK_EXISTENCE | FAILED_NOTFOUND);
-
 	return vg_handle->read_status;
 }
 
 /*
- * Returns true if the volume group already exists.
- * If unsure, it will return true. It might exist but the read failed
- * for some other reason.
- */
-uint32_t vg_might_exist(vg_t *vg_handle)
-{
-	if (!vg_handle)
-		return 1;
-
-	if (vg_handle->read_status == (FAILED_NOTFOUND | READ_CHECK_EXISTENCE))
-		return 0;
-
-	return 1;
-}
-
-/*
  * Lock a vgname and/or check for existence.
  * Takes a WRITE lock on the vgname before scanning.
  * If scanning fails or vgname found, release the lock.
-- 
1.6.0.6


