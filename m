From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:07:57 +0100
Subject: [PATCH 2/11] Provide _vg_lock_and_read, a new implementation of lock+vg_read_internal.
In-Reply-To: <1231769286-15534-2-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-3-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 14:21:23 CET 2009  Petr Rockai <me@mornfall.net>
  * Provide _vg_lock_and_read, a new implementation of lock+vg_read_internal.
  
  This is an internal function, to be later used by vg_read and
  vg_read_for_update. Not to be confused with the public function
  vg_lock_and_read, which will be removed later.
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:46.583017272 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:46.635017317 +0100
@@ -2461,6 +2461,160 @@ vg_t *vg_lock_and_read(struct cmd_contex
 	return vg;
 }
 
+static vg_t *_vg_make_handle(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     uint32_t failure)
+{
+	if (!vg)
+		if (!(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg))))
+			return_NULL;
+	vg->read_failed = failure;
+	return vg;
+}
+
+static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)
+{
+	uint32_t ret = 0;
+	if ((status & CLUSTERED) &&
+	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
+	    !lockingfailed()) {
+		log_error("Skipping clustered volume group %s", vg->name);
+		ret |= FAILED_CLUSTERED;
+	}
+
+	if ((status & EXPORTED_VG) &&
+	    (vg->status & EXPORTED_VG)) {
+		log_error("Volume group %s is exported", vg->name);
+		ret |= FAILED_EXPORTED;
+	}
+
+	if ((status & LVM_WRITE) &&
+	    !(vg->status & LVM_WRITE)) {
+		log_error("Volume group %s is read-only", vg->name);
+		ret |= FAILED_READ_ONLY;
+	}
+
+	if ((status & RESIZEABLE_VG) &&
+	    !(vg->status & RESIZEABLE_VG)) {
+		log_error("Volume group %s is not resizeable.", vg->name);
+		ret |= FAILED_RESIZEABLE;
+	}
+
+	return ret;
+}
+
+static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock,
+			 const char *vg_name, const char *vgid,
+			 uint32_t lock_flags)
+{
+	int consistent = 1;
+	struct volume_group *vg;
+
+	lock_flags &= ~LCK_TYPE_MASK;
+	lock_flags |= LCK_WRITE;
+
+	unlock_vg(cmd, lock);
+
+	dev_close_all();
+
+	if (!lock_vol(cmd, lock, lock_flags))
+		return_NULL;
+
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
+		return_NULL;
+	if (!consistent)
+		return_NULL;
+	return vg;
+}
+
+/*
+ * _vg_lock_and_read - consolidate vg locking, reading, and status flag checking
+ * This is an internal function.
+ *
+ * misc_flags:
+ *  ALLOW_INCONSISTENT: disable autocorrection
+ *
+ * Setting ALLOW_INCONSISTENT might give you inconsistent metadata. You will
+ * *still* get FAILED_INCONSISTENT in case the metadata has *really* been
+ * inconsistent. However, you still get the latest version of metadata in VG.
+ *
+ * Returns:
+ * Use vg_read_error(vg) to determine the result. Nonzero vg_read_error(vg)
+ * means there were problems reading the volume group.
+ * Zero value means that the VG is open and appropriate locks are held.
+ */
+static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+			       const char *vgid,
+			       uint32_t lock_flags, uint32_t status_flags,
+			       uint32_t misc_flags)
+{
+	struct volume_group *vg = 0;
+	const char *lock;
+ 	int consistent = 1;
+	int consistent_in;
+	uint32_t failure = 0;
+
+	if (misc_flags & ALLOW_INCONSISTENT || !(lock_flags & LCK_WRITE))
+	consistent = 0;
+
+	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  vg_name);
+		return NULL;
+	}
+
+	lock = (misc_flags & ORPHAN_LOCK ? VG_ORPHANS : vg_name);
+	if (!(misc_flags & DISABLE_LOCK)) {
+		if (!lock_vol(cmd, lock, lock_flags)) {
+			log_error("Can't get lock for %s", vg_name);
+			return _vg_make_handle(cmd, vg, FAILED_LOCKING);
+		}
+	}
+
+	if (misc_flags & ORPHAN_LOCK)
+		status_flags &= ~LVM_WRITE;
+
+	if (misc_flags & EXISTENCE_CHECK)
+		consistent = 0;
+
+	consistent_in = consistent;
+
+	/* If consistent == 1, we get NULL here if correction fails. */
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+		if (consistent_in && !consistent) {
+			log_error("Volume group \"%s\" inconsistent.", vg_name);
+			failure |= FAILED_INCONSISTENT;
+			goto_bad;
+		}
+		if (!(misc_flags & EXISTENCE_CHECK))
+			log_error("Volume group \"%s\" not found", vg_name);
+		failure |= FAILED_NOTFOUND | (misc_flags & EXISTENCE_CHECK);
+		goto_bad;
+	}
+
+	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
+	if (!consistent && !failure) {
+		vg = _recover_vg(cmd, lock, vg_name, vgid, lock_flags);
+		if (!vg) {
+			log_error("Recovery of volume group \"%s\" failed.",
+			  vg_name);
+			failure |= FAILED_INCONSISTENT;
+			goto_bad;
+		}
+	}
+
+	failure |= _vg_check_status(vg, status_flags);
+	if (failure)
+		goto_bad;
+
+	return _vg_make_handle(cmd, vg, failure);
+ bad:
+	if (failure != (FAILED_NOTFOUND | EXISTENCE_CHECK))
+		if (!(misc_flags & KEEP_LOCK) && !(misc_flags & DISABLE_LOCK))
+			unlock_vg(cmd, lock);
+	return _vg_make_handle(cmd, vg, failure);
+}
+
 /*
  * Gets/Sets for external LVM library
  */
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata-exported.h new-lvmlib_apply/lib/metadata/metadata-exported.h
--- old-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:46.583017272 +0100
+++ new-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:46.635017317 +0100
@@ -104,6 +104,32 @@ struct pv_segment;
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
+/* vg_read and vg_read_for_update flags */
+#define ALLOW_INCONSISTENT 0x1
+#define ALLOW_EXPORTED 0x2
+#define REQUIRE_RESIZEABLE 0x4
+#define EXISTENCE_CHECK 0x8
+
+#define NONBLOCKING_LOCK 0x100
+#define KEEP_LOCK 0x200
+#define DISABLE_LOCK 0x400
+#define ORPHAN_LOCK 0x800
+
+#define READ_FOR_UPDATE 0x1000
+
+/* vg's "read_failed" field */
+#define FAILED_INCONSISTENT 0x1
+#define FAILED_LOCKING 0x2
+#define FAILED_NOTFOUND 0x4
+// 0x8 is left out for EXISTENCE_CHECK
+
+#define FAILED_READ_ONLY 0x10
+#define FAILED_EXPORTED 0x20
+#define FAILED_RESIZEABLE 0x40
+#define FAILED_CLUSTERED 0x80
+
+#define FAILED_ALLOCATION 0x100
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	ALLOC_INVALID,
@@ -197,6 +223,7 @@ struct volume_group {
 	char *system_id;
 
 	uint32_t status;
+	uint32_t read_failed;
 	alloc_policy_t alloc;
 
 	uint32_t extent_size;


