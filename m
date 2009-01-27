From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jan 2009 00:40:45 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090127004045.13721.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-27 00:40:45

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Introduce as-yet-unused replacement vg_read() and vg_read_for_update()
	functions.  (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201

--- LVM2/lib/metadata/metadata-exported.h	2009/01/26 22:13:22	1.58
+++ LVM2/lib/metadata/metadata-exported.h	2009/01/27 00:40:44	1.59
@@ -387,6 +387,12 @@
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
+/* Loading volume group metadata. */
+vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+              const char *vgid, uint32_t flags);
+vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+                         const char *vgid, uint32_t flags);
+
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2009/01/26 22:43:00	1.200
+++ LVM2/lib/metadata/metadata.c	2009/01/27 00:40:44	1.201
@@ -2610,6 +2610,70 @@
 }
 
 /*
+ * vg_read: High-level volume group metadata read function.
+ *
+ * vg_read_error() must be used on any handle returned to check for errors.
+ *
+ *  - metadata inconsistent and automatic correction failed: FAILED_INCONSISTENT
+ *  - VG is read-only: FAILED_READ_ONLY
+ *  - VG is EXPORTED, unless flags has READ_ALLOW_EXPORTED: FAILED_EXPORTED
+ *  - VG is not RESIZEABLE, unless flags has ALLOW_NONRESIZEABLE:
+ *    FAILED_RESIZEABLE
+ *  - locking failed: FAILED_LOCKING
+ *
+ * On failures, all locks are released, unless LOCK_KEEP has been supplied.
+ *
+ * Volume groups are opened read-only unless flags contains READ_FOR_UPDATE.
+ *
+ * Checking for VG existence:
+ *
+ * If READ_CHECK_EXISTENCE is set in flags, if the VG exists, a non-NULL struct
+ * volume_group will be returned every time, but if it has INCONSISTENT_VG set,
+ * the other fields will be uninitialized.  You must check for INCONSISTENT_VG
+ * if passing READ_CHECK_EXISTENCE.  You also must not use it if it has
+ * INCONSISTENT_VG set.
+ *
+ * FIXME: We want vg_read to attempt automatic recovery after acquiring a
+ * temporary write lock: if that fails, we bail out as usual, with failed &
+ * FAILED_INCONSISTENT. If it works, we are good to go. Code that's been in
+ * toollib just set lock_flags to LCK_VG_WRITE and called vg_read_internal with
+ * *consistent = 1.
+ */
+vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+	      const char *vgid, uint32_t flags)
+{
+	uint32_t status = CLUSTERED;
+	uint32_t lock_flags = LCK_VG_READ;
+
+	if (flags & READ_FOR_UPDATE) {
+		status |= EXPORTED_VG | LVM_WRITE;
+		lock_flags = LCK_VG_WRITE;
+	}
+
+	if (flags & READ_ALLOW_EXPORTED)
+		status &= ~EXPORTED_VG;
+
+	if (flags & READ_REQUIRE_RESIZEABLE)
+		status |= RESIZEABLE_VG;
+
+	if (flags & LOCK_NONBLOCKING)
+		lock_flags |= LCK_NONBLOCK;
+
+	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
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
+/*
  * Gets/Sets for external LVM library
  */
 struct id pv_id(const pv_t *pv)


