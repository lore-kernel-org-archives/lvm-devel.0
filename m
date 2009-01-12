From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:08:00 +0100
Subject: [PATCH 5/11] Implement vg_read and vg_read_for_update.
In-Reply-To: <1231769286-15534-5-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
	<1231769286-15534-5-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-6-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 15:32:37 CET 2009  Petr Rockai <me@mornfall.net>
  * Implement vg_read and vg_read_for_update.
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:52.019017167 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 14:55:52.075017511 +0100
@@ -2589,6 +2589,74 @@ static vg_t *_vg_lock_and_read(struct cm
 	return _vg_make_handle(cmd, vg, failure);
 }
 
+/*
+ * vg_read: High-level volume group metadata read function.
+ *
+ * On failure, an error-indicating handle is returned. Users should use
+ * "vg_read_error" to check whether handle indicates an error or it points to
+ * valid volume group data. Moreover, vg_read_error will provide more details
+ * about the kind of failure:
+ *
+ *  - metadata inconsistent and automatic correction failed: FAILED_INCONSISTENT
+ *  - VG is read-only: FAILED_READ_ONLY
+ *  - VG is EXPORTED, unless flags has ALLOW_EXPORTED: FAILED_EXPORTED
+ *  - VG is not RESIZEABLE, unless flags has ALLOW_NONRESIZEABLE:
+ *    FAILED_RESIZEABLE
+ *  - locking failed: FAILED_LOCKING
+ *
+ * On failures, all locks are released, unless KEEP_LOCK has been supplied.
+ *
+ * By default, volume groups are opened read-only. To open a VG for updates,
+ * please use vg_read_for_update (see below).
+ *
+ * Checking for VG existence:
+ *
+ * If EXISTENCE_CHECK is set in flags, if the VG exists, a non-NULL struct
+ * volume_group will be returned every time, but if it has INCONSISTENT_VG set,
+ * the other fields will be uninitialized. You *have to* check for
+ * INCONSISTENT_VG if passing EXISTENCE_CHECK. You also *must not* use it if it
+ * has INCONSISTENT_VG set.
+ *
+ * FIXME: We want vg_read to attempt automatic recovery after acquiring a
+ * temporary write lock -- if that fails, we bail out as usual, with failed &
+ * FAILED_INCONSISTENT. If it works, we are good to go. Code that's been in
+ * toollib just set lock type to LCK_WRITE and called vg_read_internal with
+ * *consistent = 1.
+ */
+vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+	      const char *vgid, uint32_t flags)
+{
+	uint32_t status = CLUSTERED;
+	uint32_t lock = LCK_VG_READ;
+
+	if (flags & READ_FOR_UPDATE) {
+		status |= EXPORTED_VG | LVM_WRITE;
+		lock = LCK_VG_WRITE;
+	}
+
+	if (flags & ALLOW_EXPORTED)
+		status &= ~EXPORTED_VG;
+
+	if (flags & REQUIRE_RESIZEABLE)
+		status |= RESIZEABLE_VG;
+
+	if (flags & NONBLOCKING_LOCK)
+		lock |= LCK_NONBLOCK;
+
+	return _vg_lock_and_read(cmd, vg_name, vgid, lock, status, flags);
+}
+
+/*
+ * A high-level volume group metadata reading function. Open a volume group for
+ * later update (this means the user code can change the metadata and later
+ * request the new metadata to be written and committed).
+ */
+vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+			 const char *vgid, uint32_t flags)
+{
+	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE);
+}
+
 uint32_t vg_read_error(vg_t *vg) {
 	if (!vg)
 		return FAILED_ALLOCATION;
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata-exported.h new-lvmlib_apply/lib/metadata/metadata-exported.h
--- old-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:52.019017167 +0100
+++ new-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:52.075017511 +0100
@@ -380,6 +380,12 @@ vg_t *vg_lock_and_read(struct cmd_contex
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
+/* Loading volume group metadata. */
+vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+	      const char *vgid, uint32_t flags);
+vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+			 const char *vgid, uint32_t flags);
+
 /* Queries on a (possibly error-indicating) VG handle. */
 uint32_t vg_read_error(vg_t *vg);
 uint32_t vg_might_exist(vg_t *vg);


