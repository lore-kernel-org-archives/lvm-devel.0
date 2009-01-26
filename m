From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 22:13:23 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090126221323.21946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 22:13:22

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Introduce as-yet-unused _vg_lock_and_read() and associated header file
	definitions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198

--- LVM2/lib/metadata/metadata-exported.h	2009/01/26 19:01:32	1.57
+++ LVM2/lib/metadata/metadata-exported.h	2009/01/26 22:13:22	1.58
@@ -104,6 +104,29 @@
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
+/* vg_read and vg_read_for_update flags */
+#define READ_ALLOW_INCONSISTENT	0x00010000U
+#define READ_ALLOW_EXPORTED	0x00020000U
+#define READ_REQUIRE_RESIZEABLE	0x00040000U
+#define READ_CHECK_EXISTENCE	0x00080000U	/* Also used in vg->read_status */
+
+/* FIXME Deduce these next requirements internally instead of having caller specify. */
+#define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
+#define LOCK_KEEP		0x00000200U	/* Do not unlock upon read failure. */
+
+/* A meta-flag, useful with toollib for_each_* functions. */
+#define READ_FOR_UPDATE 	0x00100000U
+
+/* vg's "read_status" field */
+#define FAILED_INCONSISTENT	0x00000001U
+#define FAILED_LOCKING		0x00000002U
+#define FAILED_NOTFOUND		0x00000004U
+#define FAILED_READ_ONLY	0x00000008U
+#define FAILED_EXPORTED		0x00000010U
+#define FAILED_RESIZEABLE	0x00000020U
+#define FAILED_CLUSTERED	0x00000040U
+#define FAILED_ALLOCATION	0x00000080U
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	ALLOC_INVALID,
@@ -232,6 +255,17 @@
 	struct dm_list lvs;
 
 	struct dm_list tags;
+
+	/*
+	 * vg_t handle fields.
+	 * FIXME: Split these out.
+	 */
+
+	/*
+	 * Store result of the last vg_read().
+	 * 0 for success else appropriate FAILURE_* bits set.
+	 */
+	uint32_t read_status;
 };
 
 /* There will be one area for each stripe */
--- LVM2/lib/metadata/metadata.c	2009/01/26 19:01:32	1.197
+++ LVM2/lib/metadata/metadata.c	2009/01/26 22:13:22	1.198
@@ -2377,7 +2377,38 @@
 	return 1;
 }
 
+static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)
+{
+	uint32_t failure = 0;
+
+	if ((status & CLUSTERED) &&
+	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
+	    !lockingfailed()) {
+		log_error("Skipping clustered volume group %s", vg->name);
+		/* Return because other flags are considered undefined. */
+		return FAILED_CLUSTERED;
+	}
+
+	if ((status & EXPORTED_VG) &&
+	    (vg->status & EXPORTED_VG)) {
+		log_error("Volume group %s is exported", vg->name);
+		failure |= FAILED_EXPORTED;
+	}
 
+	if ((status & LVM_WRITE) &&
+	    !(vg->status & LVM_WRITE)) {
+		log_error("Volume group %s is read-only", vg->name);
+		failure |= FAILED_READ_ONLY;
+	}
+
+	if ((status & RESIZEABLE_VG) &&
+	    !(vg->status & RESIZEABLE_VG)) {
+		log_error("Volume group %s is not resizeable.", vg->name);
+		failure |= FAILED_RESIZEABLE;
+	}
+
+	return failure;
+}
 
 /**
  * vg_check_status - check volume group status flags and log error
@@ -2462,6 +2493,138 @@
 }
 
 /*
+ * Create a (vg_t) volume group handle from a struct volume_group pointer and a
+ * possible failure code or zero for success.
+ */
+static vg_t *_vg_make_handle(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     uint32_t failure)
+{
+	if (!vg && !(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
+		log_error("Error allocating vg handle.");
+		return_NULL;
+	}
+
+	vg->read_status = failure;
+
+	return (vg_t *)vg;
+}
+
+static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock_name,
+			 const char *vg_name, const char *vgid,
+			 uint32_t lock_flags)
+{
+	int consistent = 1;
+	struct volume_group *vg;
+
+	lock_flags &= ~LCK_TYPE_MASK;
+	lock_flags |= LCK_WRITE;
+
+	unlock_vg(cmd, lock_name);
+
+	dev_close_all();
+
+	if (!lock_vol(cmd, lock_name, lock_flags))
+		return_NULL;
+
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
+		return_NULL;
+
+	if (!consistent)
+		return_NULL;
+
+	return (vg_t *)vg;
+}
+
+/*
+ * Consolidated locking, reading, and status flag checking.
+ *
+ * If the metadata is inconsistent, setting READ_ALLOW_INCONSISTENT in
+ * misc_flags will return it with FAILED_INCONSISTENT set instead of 
+ * giving you nothing.
+ *
+ * Use vg_read_error(vg) to determine the result.  Nonzero means there were
+ * problems reading the volume group.
+ * Zero value means that the VG is open and appropriate locks are held.
+ */
+static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+			       const char *vgid, uint32_t lock_flags,
+			       uint32_t status_flags, uint32_t misc_flags)
+{
+	struct volume_group *vg = 0;
+	const char *lock_name;
+ 	int consistent = 1;
+	int consistent_in;
+	uint32_t failure = 0;
+	int already_locked;
+
+	if (misc_flags & READ_ALLOW_INCONSISTENT || !(lock_flags & LCK_WRITE))
+		consistent = 0;
+
+	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  vg_name);
+		return NULL;
+	}
+
+	lock_name = is_orphan_vg(vg_name) ? VG_ORPHANS : vg_name;
+	already_locked = vgname_is_locked(lock_name);
+
+	if (!already_locked && !lock_vol(cmd, lock_name, lock_flags)) {
+		log_error("Can't get lock for %s", vg_name);
+		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
+	}
+
+	if (is_orphan_vg(vg_name))
+		status_flags &= ~LVM_WRITE;
+
+	if (misc_flags & READ_CHECK_EXISTENCE)
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
+
+		if (!(misc_flags & READ_CHECK_EXISTENCE))
+			log_error("Volume group \"%s\" not found", vg_name);
+		else
+			failure |= READ_CHECK_EXISTENCE;
+
+		failure |= FAILED_NOTFOUND;
+		goto_bad;
+	}
+
+	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
+	if (!consistent && !failure)
+		if (!(vg = _recover_vg(cmd, lock_name, vg_name, vgid, lock_flags))) {
+			log_error("Recovery of volume group \"%s\" failed.",
+				  vg_name);
+			failure |= FAILED_INCONSISTENT;
+			goto_bad;
+		}
+	
+
+	failure |= _vg_check_status(vg, status_flags);
+	if (failure)
+		goto_bad;
+
+	return _vg_make_handle(cmd, vg, failure);
+
+bad:
+	if (failure != (FAILED_NOTFOUND | READ_CHECK_EXISTENCE) &&
+	    !(misc_flags & LOCK_KEEP) && !already_locked)
+		unlock_vg(cmd, lock_name);
+
+	return _vg_make_handle(cmd, vg, failure);
+}
+
+/*
  * Gets/Sets for external LVM library
  */
 struct id pv_id(const pv_t *pv)


