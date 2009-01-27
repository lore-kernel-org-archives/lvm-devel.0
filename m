From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jan 2009 01:48:49 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090127014849.12671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-27 01:48:48

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add as-yet-unused vg_read_error() and vg_might_exist().  (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202

--- LVM2/lib/metadata/metadata-exported.h	2009/01/27 00:40:44	1.59
+++ LVM2/lib/metadata/metadata-exported.h	2009/01/27 01:48:47	1.60
@@ -387,12 +387,20 @@
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
-/* Loading volume group metadata. */
+/*
+ * Return a handle to VG metadata.
+ */
 vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
               const char *vgid, uint32_t flags);
 vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
                          const char *vgid, uint32_t flags);
 
+/* 
+ * Test validity of a VG handle.
+ */
+uint32_t vg_read_error(vg_t *vg_handle);
+uint32_t vg_might_exist(vg_t *vg_handle);
+
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2009/01/27 00:40:44	1.201
+++ LVM2/lib/metadata/metadata.c	2009/01/27 01:48:47	1.202
@@ -2674,6 +2674,46 @@
 }
 
 /*
+ * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
+ *
+ * If READ_CHECK_EXISTENCE was supplied the non-existence of the volume group
+ * is not considered an error.
+ *
+ * !vg_read_error() && vg_might_exist() => valid handle to VG.
+ * vg_read_error() && vg_might_exist() => handle invalid, but VG might
+ *					  exist but cannot be read.
+ * !vg_read_error() && !vg_might_exist() => the VG does not exist
+ * vg_read_error() && !vg_might_exist() is impossible.
+ */
+uint32_t vg_read_error(vg_t *vg_handle)
+{
+	if (!vg_handle)
+		return FAILED_ALLOCATION;
+
+	if (vg_handle->read_status & READ_CHECK_EXISTENCE)
+		return vg_handle->read_status &
+		       ~(READ_CHECK_EXISTENCE | FAILED_NOTFOUND);
+
+	return vg_handle->read_status;
+}
+
+/*
+ * Returns true if the volume group already exists.
+ * If unsure, it will return true. It might exist but the read failed
+ * for some other reason.
+ */
+uint32_t vg_might_exist(vg_t *vg_handle)
+{
+	if (!vg_handle)
+		return 1;
+
+	if (vg_handle->read_status == (FAILED_NOTFOUND | READ_CHECK_EXISTENCE))
+		return 0;
+
+	return 1;
+}
+
+/*
  * Gets/Sets for external LVM library
  */
 struct id pv_id(const pv_t *pv)


