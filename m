From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Aug 2011 10:00:10 -0000
Subject: LVM2/lib commands/toolcontext.c metadata/segty ...
Message-ID: <20110825100010.24066.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-25 10:00:09

Modified files:
	lib/commands   : toolcontext.c 
	lib/metadata   : segtype.h 
	lib/thin       : thin.c 

Log message:
	Add registration of thin_pool segment
	
	Register thin and thin_pool segment via multiple_segtypes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/commands/toolcontext.c	2011/08/24 13:41:47	1.129
+++ LVM2/lib/commands/toolcontext.c	2011/08/25 10:00:09	1.130
@@ -1030,6 +1030,11 @@
 		return 0;
 #endif
 
+#ifdef THIN_INTERNAL
+	if (!init_thin_segtypes(cmd, &seglib))
+		return 0;
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
--- LVM2/lib/metadata/segtype.h	2011/08/24 13:41:46	1.38
+++ LVM2/lib/metadata/segtype.h	2011/08/25 10:00:09	1.39
@@ -40,6 +40,7 @@
 #define SEG_REPLICATOR_DEV	0x00000200U
 #define SEG_RAID		0x00000400U
 #define SEG_THIN		0x00000800U
+#define SEG_THIN_POOL		0x00001000U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -50,6 +51,7 @@
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
 #define seg_is_thin(seg)	((seg)->segtype->flags & SEG_THIN ? 1 : 0)
+#define seg_is_thin_pool(seg)	((seg)->segtype->flags & SEG_THIN_POOL ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
@@ -59,6 +61,7 @@
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & SEG_THIN ? 1 : 0)
+#define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
@@ -137,6 +140,10 @@
 int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#ifdef THIN_INTERNAL
+int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+#endif
+
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
 #endif
@@ -149,8 +156,4 @@
 struct segment_type *init_crypt_segtype(struct cmd_context *cmd);
 #endif
 
-#ifdef THIN_INTERNAL
-struct segment_type *init_thin_segtype(struct cmd_context *cmd);
-#endif
-
 #endif
--- LVM2/lib/thin/thin.c	2011/08/24 08:27:51	1.1
+++ LVM2/lib/thin/thin.c	2011/08/25 10:00:09	1.2
@@ -30,6 +30,22 @@
 /* Dm kernel module name for thin provisiong */
 #define THIN_MODULE "thin-pool"
 
+static const char *_thin_pool_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+
+static int _thin_pool_text_import(struct lv_segment *seg, const struct config_node *sn,
+			struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	return 1;
+}
+
+static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	return 1;
+}
 
 static const char *_thin_name(const struct lv_segment *seg)
 {
@@ -67,7 +83,7 @@
 	static int _present = 0;
 
 	if (!_checked) {
-		_present = target_present(cmd, "thin-pool", 1);
+		_present = target_present(cmd, THIN_MODULE, 1);
 		_checked = 1;
 	}
 
@@ -93,6 +109,14 @@
 	dm_free(segtype);
 }
 
+static struct segtype_handler _thin_pool_ops = {
+	.name = _thin_pool_name,
+	.text_import = _thin_pool_text_import,
+	.text_export = _thin_pool_text_export,
+	.modules_needed = _thin_modules_needed,
+	.destroy = _thin_destroy,
+};
+
 static struct segtype_handler _thin_ops = {
 	.name = _thin_name,
 	.text_import = _thin_text_import,
@@ -106,30 +130,48 @@
 };
 
 #ifdef THIN_INTERNAL
-struct segment_type *init_thin_segtype(struct cmd_context *cmd)
-#else				/* Shared */
-struct segment_type *init_segtype(struct cmd_context *cmd);
-struct segment_type *init_segtype(struct cmd_context *cmd)
+int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
+#else /* Shared */
+int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
 #endif
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
-
-	if (!segtype)
-		return_NULL;
-
-	segtype->cmd = cmd;
-	segtype->ops = &_thin_ops;
-	segtype->name = "thin";
-	segtype->private = NULL;
-	segtype->flags = SEG_THIN;
+	static const struct {
+		struct segtype_handler *ops;
+		const char name[16];
+		uint32_t flags;
+	} reg_segtypes[] = {
+		{ &_thin_pool_ops, "thin_pool", SEG_THIN_POOL },
+		{ &_thin_ops, "thin", SEG_THIN }
+	};
+
+	struct segment_type *segtype;
+	unsigned i;
+
+	for (i = 0; i < sizeof(reg_segtypes)/sizeof(reg_segtypes[0]); ++i) {
+		segtype = dm_zalloc(sizeof(*segtype));
+
+		if (!segtype) {
+			log_error("Failed to allocate memory for %s segtype",
+				  reg_segtypes[i].name);
+			return 0;
+		}
+
+		segtype->ops = reg_segtypes[i].ops;
+		segtype->name = reg_segtypes[i].name;
+		segtype->flags = reg_segtypes[i].flags;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	if (_get_thin_dso_path(cmd))
-		segtype->flags |= SEG_MONITORED;
+		if (_get_thin_dso_path(cmd))
+			segtype->flags |= SEG_MONITORED;
 #  endif	/* DMEVENTD */
 #endif
-	log_very_verbose("Initialised segtype: %s", segtype->name);
+		if (!lvm_register_segtype(seglib, segtype))
+			return_0;
 
-	return segtype;
+		log_very_verbose("Initialised segtype: %s", segtype->name);
+	}
+
+	return 1;
 }


