From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:01:23 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.h
Message-ID: <20110221120123.24174.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:01:23

Modified files:
	lib/metadata   : metadata-exported.h metadata.h 

Log message:
	Change and generalise struct format_instance for PV and VG use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.229&r2=1.230

--- LVM2/lib/metadata/metadata-exported.h	2011/02/18 14:47:30	1.176
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:01:22	1.177
@@ -170,16 +170,48 @@
 
 #define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
 
+/*
+ * These flags define the type of the format instance to be created.
+ * There are two basic types: a PV-based and a VG-based format instance.
+ * We can further control the format_instance initialisation and functionality
+ * by using the other flags. Today, the primary role of the format_instance
+ * is to temporarily store metadata area information we are working with. More
+ * flags can be defined to cover even more functionality in the future...
+ */
+
+/* PV-based format instance */
+#define FMT_INSTANCE_PV 		0x00000000U
+
+/* VG-based format instance */
+#define FMT_INSTANCE_VG 		0x00000001U
+
+/* Include any existing PV mdas during format_instance initialisation */
+#define FMT_INSTANCE_MDAS 		0x00000002U
+
+/* Include any auxiliary mdas during format_instance intialisation */
+#define FMT_INSTANCE_AUX_MDAS 		0x00000004U
+
+/* Include any other format-specific mdas during format_instance initialisation */
+#define FMT_INSTANCE_PRIVATE_MDAS 	0x00000008U
+
 struct format_instance {
+	uint32_t type;
 	const struct format_type *fmt;
+
 	/*
 	 * Each mda in a vg is on exactly one of the below lists.
 	 * MDAs on the 'in_use' list will be read from / written to
 	 * disk, while MDAs on the 'ignored' list will not be read
 	 * or written to.
 	 */
+	/* FIXME: Try to use the index only. Remove these lists. */
 	struct dm_list metadata_areas_in_use;
 	struct dm_list metadata_areas_ignored;
+	union {
+		struct metadata_area **array;
+		struct dm_hash_table *hash;
+	} metadata_areas_index;
+
 	void *private;
 };
 
--- LVM2/lib/metadata/metadata.h	2011/02/18 14:11:23	1.229
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:01:23	1.230
@@ -220,6 +220,18 @@
 	struct lv_segment *seg;
 };
 
+struct format_instance_ctx {
+	uint32_t type;
+	union {
+		const char *pv_id;
+		struct {
+			const char *vg_name;
+			const char *vg_id;
+		} vg_ref;
+		void *private;
+	} context;
+};
+
 /*
  * Ownership of objects passes to caller.
  */


