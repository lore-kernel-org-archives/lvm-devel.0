From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 15:50:01 +0000 (UTC)
Subject: master - system_id: make new VGs read-only for old lvm versions
Message-ID: <20150305155001.56DBB60C92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e65fdd9ba00ab249ab07d8b5815c398ded556e3
Commit:        1e65fdd9ba00ab249ab07d8b5815c398ded556e3
Parent:        c6a57dc4f3af6aa8912fc1f969937e3e3c47f725
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 4 11:30:53 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 09:50:43 2015 -0600

system_id: make new VGs read-only for old lvm versions

Previous versions of lvm will not obey the restrictions
imposed by the new system_id, and would allow such a VG
to be written.  So, a VG with a new system_id is further
changed to force previous lvm versions to treat it as
read-only.  This is done by removing the WRITE flag from
the metadata status line of these VGs, and putting a new
WRITE_LOCKED flag in the flags line of the metadata.

Versions of lvm that recognize WRITE_LOCKED, also obey the
new system_id.  For these lvm versions, WRITE_LOCKED is
identical to WRITE, and the rules associated with matching
system_id's are imposed.

A new VG lock_type field is also added that causes the same
WRITE/WRITE_LOCKED transformation when set.  A previous
version of lvm will also see a VG with lock_type as read-only.

Versions of lvm that recognize WRITE_LOCKED, must also obey
the lock_type setting.  Until the lock_type feature is added,
lvm will fail to read any VG with lock_type set and report an
error about an unsupported lock_type.  Once the lock_type
feature is added, lvm will allow VGs with lock_type to be
used according to the rules imposed by the lock_type.

When both system_id and lock_type settings are removed, a VG
is written with the old WRITE status flag, and without the
new WRITE_LOCKED flag.  This allows old versions of lvm to
use the VG as before.
---
 lib/format1/disk-rep.h           |    2 +
 lib/format1/import-export.c      |   16 ++++++++++-
 lib/format_text/export.c         |   31 ++++++++++++++++++++++
 lib/format_text/flags.c          |    2 +
 lib/format_text/import_vsn1.c    |   15 ++++++++++
 lib/metadata/metadata-exported.h |    5 +++-
 lib/metadata/metadata.c          |   53 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.h                |    1 +
 man/lvmsystemid.7.in             |    5 ++-
 9 files changed, 125 insertions(+), 5 deletions(-)

diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 9d1c8a5..37f7282 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -41,6 +41,7 @@
 #define	VG_WRITE             0x02	/*     "     */
 #define	VG_CLUSTERED         0x04	/*     "     */
 #define	VG_SHARED            0x08	/*     "     */
+#define	VG_WRITE_LOCKED      0x10	/*     "     */
 
 /* logical volume */
 #define	LV_ACTIVE            0x01	/* lv_status */
@@ -51,6 +52,7 @@
 #define	LV_WRITE             0x02	/*     "     */
 #define	LV_SNAPSHOT          0x04	/*     "     */
 #define	LV_SNAPSHOT_ORG      0x08	/*     "     */
+#define	LV_WRITE_LOCKED      0x10	/*     "     */
 
 #define	LV_BADBLOCK_ON       0x01	/* lv_badblock */
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 9b387e2..b898e65 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -242,6 +242,9 @@ int import_vg(struct dm_pool *mem,
 	if (vgd->vg_access & VG_WRITE)
 		vg->status |= LVM_WRITE;
 
+	if (vgd->vg_access & VG_WRITE_LOCKED)
+		vg->status |= LVM_WRITE;
+
 	if (vgd->vg_access & VG_CLUSTERED)
 		vg->status |= CLUSTERED;
 
@@ -266,9 +269,12 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 	if (vg->status & LVM_READ)
 		vgd->vg_access |= VG_READ;
 
-	if (vg->status & LVM_WRITE)
+	if ((vg->status & LVM_WRITE) && !vg_flag_write_locked(vg))
 		vgd->vg_access |= VG_WRITE;
 
+	if ((vg->status & LVM_WRITE) && vg_flag_write_locked(vg))
+		vgd->vg_access |= VG_WRITE_LOCKED;
+
 	if (vg_is_clustered(vg))
 		vgd->vg_access |= VG_CLUSTERED;
 
@@ -320,6 +326,9 @@ int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
 	if (lvd->lv_access & LV_WRITE)
 		lv->status |= LVM_WRITE;
 
+	if (lvd->lv_access & LV_WRITE_LOCKED)
+		lv->status |= LVM_WRITE;
+
 	if (lvd->lv_badblock)
 		lv->status |= BADBLOCK_ON;
 
@@ -352,9 +361,12 @@ static void _export_lv(struct lv_disk *lvd, struct volume_group *vg,
 	if (lv->status & LVM_READ)
 		lvd->lv_access |= LV_READ;
 
-	if (lv->status & LVM_WRITE)
+	if ((lv->status & LVM_WRITE) && !vg_flag_write_locked(vg))
 		lvd->lv_access |= LV_WRITE;
 
+	if ((lv->status & LVM_WRITE) && vg_flag_write_locked(vg))
+		lvd->lv_access |= LV_WRITE_LOCKED;
+
 	if (lv->status & SPINDOWN_LV)
 		lvd->lv_status |= LV_SPINDOWN;
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 8232e2f..ec01fcc 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -409,9 +409,23 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	if (fmt)
 		outfc(f, "# informational", "format = \"%s\"", fmt->name);
 
+	/*
+	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
+	 * to old versions of lvm that only look for WRITE.
+	 */
+	if ((vg->status & LVM_WRITE) && vg_flag_write_locked(vg)) {
+		vg->status &= ~LVM_WRITE;
+		vg->status |= LVM_WRITE_LOCKED;
+	}
+
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
 
+	if (vg->status & LVM_WRITE_LOCKED) {
+		vg->status |= LVM_WRITE;
+		vg->status &= ~LVM_WRITE_LOCKED;
+	}
+
 	if (!_out_tags(f, &vg->tags))
 		return_0;
  
@@ -420,6 +434,9 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	else if (vg->lvm1_system_id && *vg->lvm1_system_id)
 		outf(f, "system_id = \"%s\"", vg->lvm1_system_id);
 
+	if (vg->lock_type)
+		outf(f, "lock_type = \"%s\"", vg->lock_type);
+
 	outsize(f, (uint64_t) vg->extent_size, "extent_size = %u",
 		vg->extent_size);
 	outf(f, "max_lv = %u", vg->max_lv);
@@ -615,9 +632,23 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 
 	outf(f, "id = \"%s\"", buffer);
 
+	/*
+	 * Removing WRITE and adding WRITE_LOCKED makes it read-only
+	 * to old versions of lvm that only look for WRITE.
+	 */
+	if ((lv->status & LVM_WRITE) && vg_flag_write_locked(lv->vg)) {
+		lv->status &= ~LVM_WRITE;
+		lv->status |= LVM_WRITE_LOCKED;
+	}
+
 	if (!_print_flag_config(f, lv->status, LV_FLAGS))
 		return_0;
 
+	 if (lv->status & LVM_WRITE_LOCKED) {
+		lv->status |= LVM_WRITE;
+		lv->status &= ~LVM_WRITE_LOCKED;
+	 }
+
 	if (!_out_tags(f, &lv->tags))
 		return_0;
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index cf01271..a975606 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -34,6 +34,7 @@ static const struct flag _vg_flags[] = {
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LVM_READ, "READ", STATUS_FLAG},
 	{LVM_WRITE, "WRITE", STATUS_FLAG},
+	{LVM_WRITE_LOCKED, "WRITE_LOCKED", COMPATIBLE_FLAG},
 	{CLUSTERED, "CLUSTERED", STATUS_FLAG},
 	{SHARED, "SHARED", STATUS_FLAG},
 	{PARTIAL_VG, NULL, 0},
@@ -53,6 +54,7 @@ static const struct flag _pv_flags[] = {
 static const struct flag _lv_flags[] = {
 	{LVM_READ, "READ", STATUS_FLAG},
 	{LVM_WRITE, "WRITE", STATUS_FLAG},
+	{LVM_WRITE_LOCKED, "WRITE_LOCKED", COMPATIBLE_FLAG},
 	{FIXED_MINOR, "FIXED_MINOR", STATUS_FLAG},
 	{VISIBLE_LV, "VISIBLE", STATUS_FLAG},
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 64c08a0..6afe71d 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -550,6 +550,11 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		return 0;
 	}
 
+	if (lv->status & LVM_WRITE_LOCKED) {
+		lv->status |= LVM_WRITE;
+		lv->status &= ~LVM_WRITE_LOCKED;
+	}
+
 	if (dm_config_has_node(lvn, "creation_time")) {
 		if (!_read_uint64(lvn, "creation_time", &timestamp)) {
 			log_error("Invalid creation_time for logical volume %s.",
@@ -785,6 +790,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (dm_config_get_str(vgn, "system_id", &str))
 		strncpy(system_id, str, NAME_LEN);
 
+	if (dm_config_get_str(vgn, "lock_type", &str)) {
+		if (!(vg->lock_type = dm_pool_strdup(vg->vgmem, str)))
+			goto bad;
+	}
+
 	if (!_read_id(&vg->id, vgn, "id")) {
 		log_error("Couldn't read uuid for volume group %s.", vg->name);
 		goto bad;
@@ -802,6 +812,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	if (vg->status & LVM_WRITE_LOCKED) {
+		vg->status |= LVM_WRITE;
+		vg->status &= ~LVM_WRITE_LOCKED;
+	}
+
 	if (!_read_int32(vgn, "extent_size", &vg->extent_size)) {
 		log_error("Couldn't read extent size for volume group %s.",
 			  vg->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 758fa53..8c081d9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -122,7 +122,8 @@
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
-/* Next unused flag:		UINT64_C(0x0020000000000000)    */
+#define LVM_WRITE_LOCKED	UINT64_C(0x0020000000000000)    /* VG, LV */
+/* Next unused flag:		UINT64_C(0x0040000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -170,6 +171,7 @@
 #define FAILED_EXIST		0x00000100U
 #define FAILED_RECOVERY		0x00000200U
 #define FAILED_SYSTEMID		0x00000400U
+#define FAILED_LOCK_TYPE	0x00000800U
 #define SUCCESS			0x00000000U
 
 #define VGMETADATACOPIES_ALL UINT32_MAX
@@ -1167,6 +1169,7 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
 
+int vg_flag_write_locked(struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 68651f5..7e440a4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4257,6 +4257,37 @@ int vg_check_write_mode(struct volume_group *vg)
 }
 
 /*
+ * Return 1 if the VG metadata should be written
+ * *without* the WRITE flag in the status line, and
+ * *with* the WRITE_LOCKED flag in the flags line.
+ *
+ * If this is done for a VG, it forces previous versions
+ * of lvm (before the WRITE_LOCKED flag was added), to view
+ * the VG and its LVs as read-only (because the WRITE flag
+ * is missing).  Versions of lvm that understand the
+ * WRITE_LOCKED flag know to check the other methods of
+ * access control for the VG, specifically system_id and lock_type.
+ *
+ * So, if a VG has a system_id or lock_type, then the
+ * system_id and lock_type control access to the VG in
+ * addition to its basic writable status.  Because previous
+ * lvm versions do not know about system_id or lock_type,
+ * VGs depending on either of these should have WRITE_LOCKED
+ * instead of WRITE to prevent the previous lvm versions from
+ * assuming they can write the VG and its LVs.
+ */
+int vg_flag_write_locked(struct volume_group *vg)
+{
+	if (vg->system_id && vg->system_id[0])
+		return 1;
+
+	if (vg->lock_type && vg->lock_type[0] && strcmp(vg->lock_type, "none"))
+		return 1;
+
+	return 0;
+}
+
+/*
  * Performs a set of checks against a VG according to bits set in status
  * and returns FAILED_* bits for those that aren't acceptable.
  *
@@ -4377,6 +4408,23 @@ static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg
 	return 1;
 }
 
+static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!is_real_vg(vg->name))
+		return 1;
+
+	/*
+	 * Until lock_type support is added, reject any VG that has a lock_type.
+	 */
+	if (vg->lock_type && vg->lock_type[0] && strcmp(vg->lock_type, "none")) {
+		log_error("Cannot access VG %s with unsupported lock_type %s.",
+			  vg->name, vg->lock_type);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 {
 	/*
@@ -4468,6 +4516,11 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
 		return 0;
 	}
 
+	if (!_access_vg_lock_type(cmd, vg)) {
+		*failure |= FAILED_LOCK_TYPE;
+		return 0;
+	}
+
 	if (!_access_vg_systemid(cmd, vg)) {
 		*failure |= FAILED_SYSTEMID;
 		return 0;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 2467721..67a04a0 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -70,6 +70,7 @@ struct volume_group {
 	const char *old_name;		/* Set during vgrename and vgcfgrestore */
 	const char *system_id;
 	char *lvm1_system_id;
+	const char *lock_type;
 
 	uint32_t extent_size;
 	uint32_t extent_count;
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index c5e69be..0881b1e 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -46,8 +46,9 @@ destroyed in the following cases which the user must be careful to avoid:
 
 .IP \[bu] 2
 A host using an old version of lvm without the system_id feature will not
-recognize the system_id of other hosts' VGs and will not be stopped from
-using them.
+recognize the system_id of other hosts' VGs.  VGs with a new system_id
+are nominally protected from old versions of lvm by appearing to be
+read-only to the old versions.
 
 .IP \[bu] 2
 A VG without a system_id can be used without restriction from any host,


