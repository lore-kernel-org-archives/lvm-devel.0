From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 17:43:41 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20090727174341.22002.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 17:43:40

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add vg_reduce to metadata.c and metadata-exported.h
	
	This function behaves a little bit different than vg_reduce_single, because
	it allowes to remove even the latest pv. This has been done to be consistent
	to lvm_vg_create, which creates an empty vg.
	
	removed_pvs has been added to the volume_group struct. vg_reduce adds remove
	pvs to this list to be able to commit the changes for the pvs in lvm_vg_comm
	in liblvm2app.
	
	Initialize removed_pvs list in format-specific volume_group constructors.
	Ideally, we should have a base constructor here that initializes the general
	non-format specific members of struct volume_group.  But until then, there
	are multiple places to initialize these members.  Maybe a better patch would
	be a base constructor patch for struct volume_group.  That is more work
	though.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.269&r2=1.270

--- LVM2/lib/format1/format1.c	2009/04/10 09:59:18	1.112
+++ LVM2/lib/format1/format1.c	2009/07/27 17:43:39	1.113
@@ -132,6 +132,7 @@
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	if (!_check_vgs(pvs))
 		goto_bad;
--- LVM2/lib/format_pool/format_pool.c	2009/05/13 21:22:57	1.23
+++ LVM2/lib/format_pool/format_pool.c	2009/07/27 17:43:40	1.24
@@ -124,6 +124,7 @@
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
--- LVM2/lib/format_text/import_vsn1.c	2009/07/09 11:29:41	1.63
+++ LVM2/lib/format_text/import_vsn1.c	2009/07/27 17:43:40	1.64
@@ -753,6 +753,7 @@
 
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 12:41:09	1.102
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/27 17:43:40	1.103
@@ -243,6 +243,12 @@
 	 */
 
 	/*
+	 * List of removed physical volumes by pvreduce.
+	 * They have to get cleared on vg_commit.
+	 */
+	struct dm_list removed_pvs;
+
+	/*
 	 * Store result of the last vg_read().
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
@@ -437,6 +443,7 @@
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
+int vg_reduce(struct volume_group *vg, char *pv_name);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
--- LVM2/lib/metadata/metadata.c	2009/07/26 12:41:36	1.269
+++ LVM2/lib/metadata/metadata.c	2009/07/27 17:43:40	1.270
@@ -532,6 +532,54 @@
 	return 0;
 }
 
+/* FIXME: use this inside vgreduce_single? */
+int vg_reduce(struct volume_group *vg, char *pv_name)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+
+	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return 0;
+
+	if (!archive(vg))
+		goto bad;
+
+	/* remove each pv */
+	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+		log_error("Physical volume %s not in volume group %s.",
+			  pv_name, vg->name);
+		goto bad;
+	}
+
+	pv = pvl->pv;
+
+	if (pv_pe_alloc_count(pv)) {
+		log_error("Physical volume %s still in use.",
+			  pv_name);
+		goto bad;
+	}
+
+	if (!dev_get_size(pv_dev(pv), &pv->size)) {
+		log_error("%s: Couldn't get size.", pv_name);
+		goto bad;
+	}
+
+	vg->pv_count--;
+	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg->extent_count -= pv_pe_count(pv);
+
+	/* add pv to the remove_pvs list */
+	dm_list_del(&pvl->list);
+	dm_list_add(&vg->removed_pvs, &pvl->list);
+
+	return 1;
+
+      bad:
+	log_error("Unable to remove physical volume '%s' from "
+		  "volume group '%s'.", pv_name, vg->name);
+	return 0;
+}
+
 const char *strip_dir(const char *vg_name, const char *dev_dir)
 {
 	size_t len = strlen(dev_dir);
@@ -660,6 +708,9 @@
 
 	dm_list_init(&vg->tags);
 
+	/* initialize removed_pvs list */
+	dm_list_init(&vg->removed_pvs);
+
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
 						       NULL, NULL))) {
 		log_error("Failed to create format instance");
@@ -2165,6 +2216,7 @@
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 	vg->vgmem = mem;
 	vg->cmd = cmd;
 	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {


