From: Dave Wysochanski <wysochanski@pobox.com>
Date: Tue, 23 Nov 2010 00:01:09 -0500
Subject: [PATCH 1/2] Update errno codes for vg_read() and lvm2app lvm_vg_open().
In-Reply-To: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
References: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290488470-21743-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update errno codes for vg_read error paths:
- EINVAL: invalid vg_name
- ENOLCK: lock_vol fails
- ENODEV: VG 'vgname' does not exist
- EPROTOTYPE: VG is clustered but locking not clustered
- EROFS: VG is read-only
- EUCLEAN: VG is inconsistent

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/metadata/metadata.c |   23 ++++++++++++++---------
 liblvm/lvm2app.h        |    8 ++++++++
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61b4600..18917f9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3532,7 +3532,8 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 
 	if ((status & CLUSTERED) &&
 	    (vg_is_clustered(vg)) && !locking_is_clustered()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		log_errno(EPROTOTYPE,
+			  "Skipping clustered volume group %s", vg->name);
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
 	}
@@ -3545,7 +3546,7 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 
 	if ((status & LVM_WRITE) &&
 	    !(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", vg->name);
+		log_errno(EROFS, "Volume group %s is read-only", vg->name);
 		failure |= FAILED_READ_ONLY;
 	}
 
@@ -3617,7 +3618,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_errno(EINVAL, "Volume group name %s has invalid characters",
 			  vg_name);
 		return NULL;
 	}
@@ -3626,7 +3627,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
 	    !lock_vol(cmd, vg_name, lock_flags)) {
-		log_error("Can't get lock for %s", vg_name);
+		log_errno(ENOLCK, "Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
 
@@ -3638,19 +3639,21 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	/* If consistent == 1, we get NULL here if correction fails. */
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
-			log_error("Volume group \"%s\" inconsistent.", vg_name);
+			log_errno(EUCLEAN,
+				  "Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto_bad;
 		}
 
-		log_error("Volume group \"%s\" not found", vg_name);
+		log_errno(ENODEV, "Volume group \"%s\" not found", vg_name);
 
 		failure |= FAILED_NOTFOUND;
 		goto_bad;
 	}
 
 	if (vg_is_clustered(vg) && !locking_is_clustered()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		log_errno(EPROTOTYPE,
+			  "Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto_bad;
 	}
@@ -3659,7 +3662,8 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	if (!consistent && !failure) {
 		vg_release(vg);
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
-			log_error("Recovery of volume group \"%s\" failed.",
+			log_errno(EUCLEAN,
+				  "Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto_bad;
@@ -3681,7 +3685,8 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) &&
 	    lock_flags == LCK_VG_WRITE) {
-		log_error("Cannot change VG %s with unknown segments in it!",
+		log_errno(EUCLEAN,
+			  "Cannot change VG %s with unknown segments in it!",
 			  vg->name);
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
 		goto_bad;
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index d6378ac..86fd6c6 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -466,6 +466,14 @@ const char *lvm_vgname_from_device(lvm_t libh, const char *device);
  * Open flags - currently ignored.
  *
  * \return  non-NULL VG handle (success) or NULL (failure).
+ * In the case of a failure, lvm_errno() may be used to retrieve the specific
+ * error.  The errno codes for various errors are as follows:
+ * EINVAL: Invalid characters in 'vgname' or 'mode'.
+ * ENOLCK: Unable to obtain VG lock.
+ * ENODEV: Unable to find 'vgname' on system.
+ * EPROTOTYPE: Volume group 'vgname' is clustered but locking not clustered.
+ * EROFS: Volume group 'vgname' is read-only
+ * EUCLEAN: Volume group 'vgname' inconsistent
  */
 vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags);
-- 
1.7.2.2


