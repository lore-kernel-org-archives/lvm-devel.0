From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 17:59:35 -0000
Subject: LVM2 daemons/lvmetad/lvmetad-client.h daemons/ ...
Message-ID: <20120223175935.18741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 17:59:33

Modified files:
	daemons/lvmetad: lvmetad-client.h lvmetad-core.c 
	lib/cache      : lvmcache.h lvmetad.c 
	lib/format_text: format-text.c 

Log message:
	Some reformating for lvmetad uddates
	
	cleanup gcc warning,
	use PRIu64
	header cleanups
	const pointer fixes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195

--- LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 13:11:08	1.7
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 17:59:32	1.8
@@ -30,9 +30,6 @@
 	struct dm_config_tree *cft;
 } lvmetad_vg;
 
-static inline daemon_handle lvmetad_open();
-static inline void lvmetad_close(daemon_handle h);
-
 /* Get a list of VG UUIDs that match a given VG name. */
 lvmetad_uuidlist lvmetad_lookup_vgname(daemon_handle h, const char *name);
 
--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/21 09:19:08	1.38
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/23 17:59:32	1.39
@@ -226,10 +226,12 @@
 
 static void merge_pvmeta(struct dm_config_node *pv, struct dm_config_node *pvmeta)
 {
+	struct dm_config_node *tmp;
+
 	if (!pvmeta)
 		return;
 
-	struct dm_config_node *tmp = pvmeta;
+	tmp = pvmeta;
 	while (tmp->sib) {
 		/* drop the redundant ID and dev_size nodes */
 		if (!strcmp(tmp->sib->key, "id") || !strcmp(tmp->sib->key, "dev_size"))
@@ -286,6 +288,8 @@
 {
 	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid), *vgname = NULL;
+	struct dm_config_node *pv;
+	struct dm_config_node *cn = NULL;
 
 	if (!pvmeta)
 		return NULL;
@@ -297,7 +301,7 @@
 	}
 
 	/* Nick the pvmeta config tree. */
-	struct dm_config_node *pv = dm_config_clone_node(cft, pvmeta->root, 0);
+	pv = dm_config_clone_node(cft, pvmeta->root, 0);
 	if (pre_sib)
 		pre_sib->sib = pv;
 	if (parent && !parent->child)
@@ -306,7 +310,6 @@
 	pv->key = pvid;
 
 	/* Add the "variable" bits to it. */
-	struct dm_config_node *cn = NULL;
 
 	if (vgid && strcmp(vgid, "#orphan"))
 		cn = make_text_node(cft, "vgid", vgid, pv, cn);
@@ -319,6 +322,8 @@
 static response pv_list(lvmetad_state *s, request r)
 {
 	struct dm_config_node *cn = NULL, *cn_pvs;
+	struct dm_hash_node *n;
+	const char *id;
 	response res = { .buffer = NULL };
 	res.cft = dm_config_create();
 
@@ -328,9 +333,9 @@
 
 	lock_pvid_to_pvmeta(s);
 
-	struct dm_hash_node *n = dm_hash_get_first(s->pvid_to_pvmeta);
+	n = dm_hash_get_first(s->pvid_to_pvmeta);
 	while (n) {
-		const char *id = dm_hash_get_key(s->pvid_to_pvmeta, n);
+		id = dm_hash_get_key(s->pvid_to_pvmeta, n);
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
 		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
 	}
@@ -344,21 +349,21 @@
 {
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t devt = daemon_request_int(r, "device", 0);
+	response res = { .buffer = NULL };
+	struct dm_config_node *pv;
+
 	if (!pvid && !devt)
 		return daemon_reply_simple("failed", "reason = %s", "need PVID or device", NULL);
 
-	response res = { .buffer = NULL };
 	res.cft = dm_config_create();
 	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
 
-	struct dm_config_node *pv;
-
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && devt)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
 
 	if (!pvid) {
-		debug("pv_lookup: could not find device %lld\n", devt);
+		debug("pv_lookup: could not find device %" PRIu64 "\n", devt);
 		unlock_pvid_to_pvmeta(s);
 		return daemon_reply_simple("failed", "reason = %s", "device not found", NULL);
 	}
@@ -378,6 +383,9 @@
 static response vg_list(lvmetad_state *s, request r)
 {
 	struct dm_config_node *cn, *cn_vgs, *cn_last = NULL;
+	struct dm_hash_node *n;
+	const char *id;
+	const char *name;
 	response res = { .buffer = NULL };
 	res.cft = dm_config_create();
 
@@ -395,10 +403,10 @@
 
 	lock_vgid_to_metadata(s);
 
-	struct dm_hash_node *n = dm_hash_get_first(s->vgid_to_vgname);
+	n = dm_hash_get_first(s->vgid_to_vgname);
 	while (n) {
-		const char *id = dm_hash_get_key(s->vgid_to_vgname, n),
-			 *name = dm_hash_get_data(s->vgid_to_vgname, n);
+		id = dm_hash_get_key(s->vgid_to_vgname, n),
+		name = dm_hash_get_data(s->vgid_to_vgname, n);
 
 		cn = dm_config_create_node(res.cft, id);
 		if (cn_last)
@@ -433,17 +441,17 @@
 	struct dm_config_node *metadata, *n;
 	response res = { .buffer = NULL };
 
-	const char *uuid = daemon_request_str(r, "uuid", NULL),
-		   *name = daemon_request_str(r, "name", NULL);
+	const char *uuid = daemon_request_str(r, "uuid", NULL);
+	const char *name = daemon_request_str(r, "name", NULL);
 
 	debug("vg_lookup: uuid = %s, name = %s\n", uuid, name);
 
 	if (!uuid || !name) {
 		lock_vgid_to_metadata(s);
 		if (name && !uuid)
-			uuid = dm_hash_lookup(s->vgname_to_vgid, (void *)name);
+			uuid = dm_hash_lookup(s->vgname_to_vgid, name);
 		if (uuid && !name)
-			name = dm_hash_lookup(s->vgid_to_vgname, (void *)uuid);
+			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
 	}
 
@@ -539,22 +547,24 @@
 {
 	struct dm_config_node *pv = pvs(vg->root);
 	struct dm_hash_table *to_check = dm_hash_create(32);
+	struct dm_hash_node *n;
+	const char *pvid;
+	const char *vgid_old;
 
 	if (!vgid)
 		return 0;
 
 	while (pv) {
-		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
-		const char *vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		pvid = dm_config_find_str(pv->child, "id", NULL);
+		vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
 		if (vgid_old && nuke_empty)
 			dm_hash_insert(to_check, vgid_old, (void*) 1);
-		dm_hash_insert(s->pvid_to_vgid, pvid, (void *) vgid);
+		dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid);
 		debug("remap PV %s to VG %s\n", pvid, vgid);
 		pv = pv->sib;
 	}
 
-	struct dm_hash_node *n = dm_hash_get_first(to_check);
-
+	n = dm_hash_get_first(to_check);
 	while (n) {
 		const char *check_vgid = dm_hash_get_key(to_check, n);
 		lock_vg(s, check_vgid);
@@ -594,17 +604,17 @@
 /* The VG must be locked. */
 static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
 {
+	struct dm_config_tree *vg;
+	struct dm_config_node *pv;
+	int missing = 1;
+
 	if (!vgid)
 		return 0;
 
-	struct dm_config_tree *vg = dm_hash_lookup(s->vgid_to_metadata, vgid);
-	if (!vg)
+	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, vgid)))
 		return 1;
 
-	struct dm_config_node *pv = pvs(vg->root);
-
-	int missing = 1;
-
+	pv = pvs(vg->root);
 	lock_pvid_to_pvmeta(s);
 
 	while (pv) {
@@ -700,7 +710,7 @@
 	dm_hash_insert(s->vgid_to_metadata, vgid, cft);
 	debug("Mapping %s to %s\n", vgid, name);
 	dm_hash_insert(s->vgid_to_vgname, vgid, dm_pool_strdup(dm_config_memory(cft), name));
-	dm_hash_insert(s->vgname_to_vgid, name, (void *)vgid);
+	dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid);
 	unlock_vgid_to_metadata(s);
 
 	update_pvid_to_vgid(s, cft, vgid, 1);
@@ -714,11 +724,11 @@
 
 static response pv_gone(lvmetad_state *s, request r)
 {
-	int found = 0;
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t device = daemon_request_int(r, "device", 0);
+	struct dm_config_tree *pvmeta;
 
-	debug("pv_gone: %s / %lld\n", pvid, device);
+	debug("pv_gone: %s / %" PRIu64 "\n", pvid, device);
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && device > 0)
@@ -728,9 +738,9 @@
 		return daemon_reply_simple("failed", "reason = %s", "device not in cache", NULL);
 	}
 
-	debug("pv_gone (updated): %s / %lld\n", pvid, device);
+	debug("pv_gone (updated): %s / %" PRIu64 "\n", pvid, device);
 
-	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
@@ -751,7 +761,9 @@
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
-
+	struct dm_config_tree *cft;
+	const char *old;
+	const char *pvid_dup;
 	int complete = 0, orphan = 0;
 
 	if (!pvid)
@@ -762,20 +774,19 @@
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
 		return daemon_reply_simple("failed", "reason = %s", "need PV device number", NULL);
 
-	debug("pv_found %s, vgid = %s, device = %lld\n", pvid, vgid, device);
+	debug("pv_found %s, vgid = %s, device = %" PRIu64 "\n", pvid, vgid, device);
 
 	lock_pvid_to_pvmeta(s);
-	{
-		const char *old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-		if (old)
-			dm_hash_remove(s->pvid_to_pvmeta, old);
-
-		struct dm_config_tree *cft = dm_config_create();
-		cft->root = dm_config_clone_node(cft, pvmeta, 0);
-		const char *pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
-		dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
-		dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
-	}
+
+	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device))))
+		dm_hash_remove(s->pvid_to_pvmeta, old);
+
+	cft = dm_config_create();
+	cft->root = dm_config_clone_node(cft, pvmeta, 0);
+	pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
+	dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
+	dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
+
 	unlock_pvid_to_pvmeta(s);
 
 	if (metadata) {
@@ -797,12 +808,11 @@
 	}
 
 	if (vgid) {
-		struct dm_config_tree *cft = lock_vg(s, vgid);
-		if (cft) {
+		if ((cft = lock_vg(s, vgid)))
 			complete = update_pv_status(s, cft, cft->root, 0);
-		} else if (!strcmp(vgid, "#orphan")) {
+		else if (!strcmp(vgid, "#orphan"))
 			orphan = 1;
-		} else {
+		else {
 			unlock_vg(s, vgid);
 			return daemon_reply_simple("failed", "reason = %s",
 						   "internal treason!", NULL);
--- LVM2/lib/cache/lvmcache.h	2012/02/23 13:11:08	1.43
+++ LVM2/lib/cache/lvmcache.h	2012/02/23 17:59:32	1.44
@@ -39,7 +39,7 @@
 struct lvmcache_vginfo;
 
 int lvmcache_init(void);
-void lvmcache_allow_reads_with_lvmetad();
+void lvmcache_allow_reads_with_lvmetad(void);
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
 
--- LVM2/lib/cache/lvmetad.c	2012/02/23 13:11:08	1.1
+++ LVM2/lib/cache/lvmetad.c	2012/02/23 17:59:32	1.2
@@ -46,17 +46,26 @@
 		     const struct dm_config_node *cn)
 {
 	struct metadata_area_ops *ops;
-	struct metadata_area *mda = NULL;
-	dm_list_iterate_items(ops, &fmt->mda_ops) {
+
+	dm_list_iterate_items(ops, &fmt->mda_ops)
 		if (ops->mda_import_text && ops->mda_import_text(info, cn))
 			return 1;
-	}
+
 	return 0;
 }
 
 static struct lvmcache_info *_pv_populate_lvmcache(
 	struct cmd_context *cmd, struct dm_config_node *cn, dev_t fallback)
 {
+	struct device *device;
+	struct id pvid, vgid;
+	char mda_id[32];
+	char da_id[32];
+	int i = 0;
+	struct dm_config_node *mda = NULL;
+	struct dm_config_node *da = NULL;
+	uint64_t offset, size;
+	struct lvmcache_info *info;
 	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
 		   *vgid_txt = dm_config_find_str(cn->child, "vgid", NULL),
 		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
@@ -69,23 +78,21 @@
 
 	if (!fmt) {
 		log_warn("No format for PV %s. It is probably missing.", pvid_txt);
-		return_NULL;
+		return NULL;
 	}
 
-	struct device *device = dev_cache_get_by_devt(devt, cmd->filter);
-	struct id pvid, vgid;
-
+	device = dev_cache_get_by_devt(devt, cmd->filter);
 	if (!device && fallback)
 		device = dev_cache_get_by_devt(fallback, cmd->filter);
 
 	if (!device) {
 		log_warn("No device for PV %s.", pvid_txt);
-		return_NULL;
+		return NULL;
 	}
 
 	if (!pvid_txt || !id_read_format(&pvid, pvid_txt)) {
 		log_warn("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
-		return_NULL;
+		return NULL;
 	}
 
 	if (vgid_txt)
@@ -96,19 +103,15 @@
 	if (!vgname)
 		vgname = fmt->orphan_vg_name;
 
-	struct lvmcache_info *info =
-		lvmcache_add(fmt->labeller, (const char *)&pvid, device,
-			     vgname, (const char *)&vgid, 0);
+	info = lvmcache_add(fmt->labeller, (const char *)&pvid, device,
+			    vgname, (const char *)&vgid, 0);
 
 	lvmcache_get_label(info)->sector = label_sector;
 	lvmcache_set_device_size(info, devsize);
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);
 
-	int i = 0;
-	struct dm_config_node *mda = NULL;
 	do {
-		char mda_id[32];
 		sprintf(mda_id, "mda%d", i);
 		mda = dm_config_find_node(cn->child, mda_id);
 		if (mda)
@@ -117,13 +120,10 @@
 	} while (mda);
 
 	i = 0;
-	struct dm_config_node *da = NULL;
 	do {
-		char da_id[32];
 		sprintf(da_id, "da%d", i);
 		da = dm_config_find_node(cn->child, da_id);
 		if (da) {
-			uint64_t offset, size;
 			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
 			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
 			lvmcache_add_da(info, offset, size);
@@ -136,14 +136,24 @@
 
 struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
+	struct volume_group *vg = NULL;
+	daemon_reply reply;
+	char uuid[64];
+	struct format_instance *fid;
+	struct format_instance_ctx fic;
+	struct dm_config_node *top;
+	const char *name;
+	const char *fmt_name;
+	struct format_type *fmt;
+	struct dm_config_node *pvcn;
+	struct pv_list *pvl;
+	struct lvmcache_info *info;
+
 	if (!_using_lvmetad)
 		return NULL;
 
-	struct volume_group *vg = NULL;
-	daemon_reply reply;
 	if (vgid) {
-		char uuid[64];
-		id_write_format((struct id*)vgid, uuid, 64);
+		id_write_format((const struct id*)vgid, uuid, 64);
 		reply = daemon_send_simple(_lvmetad, "vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)
@@ -153,16 +163,12 @@
 
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 
-		struct dm_config_node *top = dm_config_find_node(reply.cft->root, "metadata");
-		const char *name = daemon_reply_str(reply, "name", NULL);
-
-		struct format_instance *fid;
-		struct format_instance_ctx fic;
+		top = dm_config_find_node(reply.cft->root, "metadata");
+		name = daemon_reply_str(reply, "name", NULL);
 
 		/* fall back to lvm2 if we don't know better */
-		const char *fmt_name = dm_config_find_str(top, "metadata/format", "lvm2");
-		struct format_type *fmt = get_format_by_name(cmd, fmt_name);
-		if (!fmt) {
+		fmt_name = dm_config_find_str(top, "metadata/format", "lvm2");
+		if (!(fmt = get_format_by_name(cmd, fmt_name))) {
 			log_error(INTERNAL_ERROR
 				  "We do not know the format (%s) reported by lvmetad.",
 				  fmt_name);
@@ -176,8 +182,7 @@
 		if (!(fid = fmt->ops->create_instance(fmt, &fic)))
 			return_NULL;
 
-		struct dm_config_node *pvcn =
-			dm_config_find_node(top, "metadata/physical_volumes")->child;
+		pvcn = dm_config_find_node(top, "metadata/physical_volumes")->child;
 		while (pvcn) {
 			_pv_populate_lvmcache(cmd, pvcn, 0);
 			pvcn = pvcn->sib;
@@ -186,11 +191,8 @@
 		top->key = name;
 		vg = import_vg_from_config_tree(reply.cft, fid);
 
-		struct pv_list *pvl;
 		dm_list_iterate_items(pvl, &vg->pvs) {
-			struct lvmcache_info *info =
-				lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0);
-			if (info) {
+			if ((info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
 				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
 				pvl->pv->dev = lvmcache_device(info);
 				lvmcache_fid_add_mdas_pv(info, fid);
@@ -221,8 +223,17 @@
 int lvmetad_vg_update(struct volume_group *vg)
 {
 	char *buf = NULL;
+	daemon_reply reply;
+	struct dm_hash_node *n;
+	struct metadata_area *mda;
+	char mda_id[128], *num;
+	struct pv_list *pvl;
+	struct lvmcache_info *info;
+	struct _fixup_baton baton = { .i = 0 };
+
 	if (!vg)
 		return 0;
+
 	if (!_using_lvmetad)
 		return 1; /* fake it */
 
@@ -237,8 +248,6 @@
 		return_0;
 	}
 
-	daemon_reply reply;
-
 	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
 				             "metadata = %b", strchr(buf, '{'),
 				   NULL);
@@ -246,26 +255,23 @@
 	if (!_lvmetad_handle_reply(reply, "update VG", vg->name))
 		return 0;
 
-	struct dm_hash_node *n = (vg->fid && vg->fid->metadata_areas_index) ?
+	n = (vg->fid && vg->fid->metadata_areas_index) ?
 		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
 	while (n) {
-		struct metadata_area *mda = dm_hash_get_data(vg->fid->metadata_areas_index, n);
-		char mda_id[128], *num;
+		mda = dm_hash_get_data(vg->fid->metadata_areas_index, n);
 		strcpy(mda_id, dm_hash_get_key(vg->fid->metadata_areas_index, n));
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
-			struct lvmcache_info *info =
-				lvmcache_info_from_pvid(mda_id, 0);
-			struct _fixup_baton baton = { .i = 0, .find = atoi(num),
-						      .ignore = mda_is_ignored(mda) };
-			if (info)
+			if ((info = lvmcache_info_from_pvid(mda_id, 0))) {
+				baton.find = atoi(num);
+				baton.ignore = mda_is_ignored(mda);
 				lvmcache_foreach_mda(info, _fixup_ignored, &baton);
+			}
 		}
 		n = dm_hash_get_next(vg->fid->metadata_areas_index, n);
 	}
 
-	struct pv_list *pvl;
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
 		if (pvl->pv->dev && !lvmetad_pv_found(pvl->pv->id, pvl->pv->dev,
@@ -279,34 +285,38 @@
 
 int lvmetad_vg_remove(struct volume_group *vg)
 {
+	char uuid[64];
+	daemon_reply reply;
+
 	if (!_using_lvmetad)
 		return 1; /* just fake it */
-	char uuid[64];
+
 	id_write_format(&vg->id, uuid, 64);
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
+	reply = daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
 
 	return _lvmetad_handle_reply(reply, "remove VG", vg->name);
 }
 
 int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid)
 {
+	char uuid[64];
+	daemon_reply reply;
+	int result = 1;
+	struct dm_config_node *cn;
+
 	if (!_using_lvmetad)
 		return_0;
 
-	int result = 1;
-	char uuid[64];
 	id_write_format(&pvid, uuid, 64);
 
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
+	reply = daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
 
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		_lvmetad_handle_reply(reply, "lookup PVs", "");
 		return_0;
 	}
 
-	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volume");
+	cn = dm_config_find_node(reply.cft->root, "physical_volume");
 	if (!_pv_populate_lvmcache(cmd, cn, 0))
 		result = 0;
 
@@ -316,20 +326,21 @@
 
 int lvmetad_pv_lookup_by_devt(struct cmd_context *cmd, dev_t device)
 {
+	int result = 1;
+	daemon_reply reply;
+	struct dm_config_node *cn;
+
 	if (!_using_lvmetad)
 		return_0;
 
-	int result = 1;
-
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", device, NULL);
+	reply = daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", device, NULL);
 
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		_lvmetad_handle_reply(reply, "lookup PVs", "");
 		return_0;
 	}
 
-	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volume");
+	cn = dm_config_find_node(reply.cft->root, "physical_volume");
 	if (!_pv_populate_lvmcache(cmd, cn, device))
 		result = 0;
 
@@ -339,18 +350,20 @@
 
 int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 {
+	daemon_reply reply;
+	struct dm_config_node *cn;
+
 	if (!_using_lvmetad)
 		return_0;
 
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "pv_list", NULL);
+	reply = daemon_send_simple(_lvmetad, "pv_list", NULL);
 
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		_lvmetad_handle_reply(reply, "list PVs", "");
 		return_0;
 	}
 
-	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volumes")->child;
+	cn = dm_config_find_node(reply.cft->root, "physical_volumes")->child;
 	while (cn) {
 		_pv_populate_lvmcache(cmd, cn, 0);
 		cn = cn->sib;
@@ -362,28 +375,29 @@
 
 int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 {
+	struct volume_group *tmp;
+	struct id vgid;
+	const char *vgid_txt;
+	daemon_reply reply;
+	struct dm_config_node *cn;
+
 	if (!_using_lvmetad)
 		return_0;
 
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "vg_list", NULL);
-
+	reply = daemon_send_simple(_lvmetad, "vg_list", NULL);
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		_lvmetad_handle_reply(reply, "list VGs", "");
 		return_0;
 	}
 
-	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "volume_groups")->child;
+	cn = dm_config_find_node(reply.cft->root, "volume_groups")->child;
 	while (cn) {
-		struct id vgid;
-		const char *vgid_txt = cn->key,
-			   *name = dm_config_find_str(cn->child, "name", NULL);
+		vgid_txt = cn->key;
 		id_read_format(&vgid, vgid_txt);
-
 		cn = cn->sib;
 
 		/* the call to lvmetad_vg_lookup will poke the VG into lvmcache */
-		struct volume_group *tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
+		tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
 		release_vg(tmp);
 	}
 
@@ -400,12 +414,13 @@
 {
 	int result = 0;
 	struct _print_mda_baton *b = baton;
+	char *buf, *mda_txt;
 
 	if (!mda->ops->mda_export_text) /* do nothing */
 		return 1;
 
-	char *buf = b->buffer;
-	char *mda_txt = mda->ops->mda_export_text(mda);
+	buf = b->buffer;
+	mda_txt = mda->ops->mda_export_text(mda);
 	if (!dm_asprintf(&b->buffer, "%s mda%i { %s }", b->buffer ?: "", b->i, mda_txt))
 		goto_out;
 	b->i ++;
@@ -418,13 +433,16 @@
 
 static int _print_da(struct disk_locn *da, void *baton)
 {
+	struct _print_mda_baton *b;
+	char *buf;
+
 	if (!da)
 		return 1;
 
-	struct _print_mda_baton *b = baton;
-
-	char *buf = b->buffer;
-	if (!dm_asprintf(&b->buffer, "%s da%i { offset = %lld size = %lld }",
+	b = baton;
+	buf = b->buffer;
+	if (!dm_asprintf(&b->buffer, "%s da%i { offset = %" PRIu64
+			 " size = %" PRIu64 " }",
 			 b->buffer ?: "", b->i, da->offset, da->size))
 	{
 		dm_free(buf);
@@ -432,52 +450,55 @@
 	}
 	b->i ++;
 	dm_free(buf);
+
 	return 1;
 }
 
 static const char *_print_mdas(struct lvmcache_info *info)
 {
 	struct _print_mda_baton baton = { .i = 0, .buffer = NULL };
+
 	if (!lvmcache_foreach_mda(info, &_print_mda, &baton))
 		return NULL;
 	baton.i = 0;
 	if (!lvmcache_foreach_da(info, &_print_da, &baton))
 		return NULL;
+
 	return baton.buffer;
 }
 
 int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_type *fmt,
 		     uint64_t label_sector, struct volume_group *vg)
 {
+	char uuid[64];
+	daemon_reply reply;
+	struct lvmcache_info *info;
+	const char *mdas = NULL;
+	char *pvmeta;
+	char *buf = NULL;
+
 	if (!_using_lvmetad)
 		return 1;
 
-	char uuid[64];
-
 	id_write_format(&pvid, uuid, 64);
 
 	/* FIXME A more direct route would be much preferable. */
-	struct lvmcache_info *info = lvmcache_info_from_pvid((const char *)&pvid, 0);
-	const char *mdas = NULL;
-	if (info)
+	if ((info = lvmcache_info_from_pvid((const char *)&pvid, 0)))
 		mdas = _print_mdas(info);
 
-	char *pvmeta;
 	if (!dm_asprintf(&pvmeta,
-			 "{ device = %lld\n"
-			 "  dev_size = %lld\n"
+			 "{ device = %" PRIu64 "\n"
+			 "  dev_size = %" PRIu64 "\n"
 			 "  format = \"%s\"\n"
-			 "  label_sector = %lld\n"
+			 "  label_sector = %" PRIu64 "\n"
 			 "  id = \"%s\"\n"
 			 "  %s"
-			 "}", device->dev, info ? lvmcache_device_size(info) : 0,
+			 "}", device->dev,
+			 info ? lvmcache_device_size(info) : 0,
 			 fmt->name, label_sector, uuid, mdas ?: ""))
 		return_0;
 
-	daemon_reply reply;
-
 	if (vg) {
-		char *buf = NULL;
 		/*
 		 * TODO. This is not entirely correct, since export_vg_to_buffer
 		 * adds trailing garbage to the buffer. We may need to use
@@ -513,7 +534,7 @@
 	return _lvmetad_handle_reply(reply, "drop PV", "");
 }
 
-int lvmetad_active()
+int lvmetad_active(void)
 {
 	return _using_lvmetad;
 }
@@ -545,15 +566,20 @@
 static dev_t _parse_devt(const char *str) { /* Oh. */
 	char *where = (char *) str;
 	int major = strtol(str, &where, 10);
+	int minor;
+
 	if (where == str)
 		return -1;
+
 	if (*where != ':')
 		return -1;
-	++where;
-	str = where;
-	int minor = strtol(str, &where, 10);
+
+	str = ++where;
+	minor = strtol(str, &where, 10);
+
 	if (where == str)
 		return -1;
+
 	if (*where)
 		return -1;
 
@@ -562,6 +588,14 @@
 
 int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct device *dev;
+	struct label *label;
+	struct lvmcache_info *info;
+	struct physical_volume pv;
+	struct _pvscan_lvmetad_baton baton;
+	/* Create a dummy instance. */
+	struct format_instance_ctx fic = { .type = 0 };
+
 	if (argc != 1) {
 		log_error("Exactly one device parameter required.");
 		return 0;
@@ -572,7 +606,7 @@
 		return 0;
 	}
 
-	struct device *dev = dev_cache_get(argv[0], NULL);
+	dev = dev_cache_get(argv[0], NULL);
 	if (!dev && _parse_devt(argv[0]) != -1)
 		dev = dev_cache_get_by_devt(_parse_devt(argv[0]), NULL);
 
@@ -589,7 +623,6 @@
 		return 1;
 	}
 
-	struct label *label;
 	if (!label_read(dev, &label, 0)) {
 		log_warn("No PV label found on %s.", dev_name(dev));
 		if (!lvmetad_pv_gone(dev->dev))
@@ -597,18 +630,12 @@
 		return 1;
 	}
 
-	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
-	struct physical_volume pv;
+	info = (struct lvmcache_info *) label->info;
 	memset(&pv, 0, sizeof(pv));
 
-	struct _pvscan_lvmetad_baton baton;
 	baton.vg = NULL;
-
-	/* Create a dummy instance. */
-	struct format_instance_ctx fic = { .type = 0 };
-	baton.fid =
-		lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
-	struct metadata_area *mda;
+	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info),
+							     &fic);
 
 	lvmcache_foreach_mda(info, _pvscan_lvmetad_single, &baton);
 
--- LVM2/lib/format_text/format-text.c	2012/02/23 13:11:09	1.194
+++ LVM2/lib/format_text/format-text.c	2012/02/23 17:59:33	1.195
@@ -1607,30 +1607,39 @@
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 	char *result;
+
 	dm_asprintf(&result,
 		    "ignore = %d "
 		    "start = %" PRIu64" "
 		    "size = %" PRIu64 " "
 		    "free_sectors = %" PRIu64,
 		    mda_is_ignored(mda), mdc->area.start, mdc->area.size, mdc->free_sectors);
+
 	return result;
 }
 
 static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn)
 {
+	struct device *device;
+	uint64_t offset;
+	uint64_t size;
+	int ignore;
+
 	if (!cn->child)
 		return 0;
-	cn = cn->child;
 
-	struct device *device = lvmcache_device(info);
-	uint64_t offset = dm_config_find_int(cn, "start", 0);
-	uint64_t size = dm_config_find_int(cn, "size", 0);
-	int ignore = dm_config_find_int(cn, "ignore", 0);
+	cn = cn->child;
+	device = lvmcache_device(info);
+	size = dm_config_find_int(cn, "size", 0);
 
 	if (!device || !size)
 		return 0;
 
+	offset = dm_config_find_int(cn, "start", 0);
+	ignore = dm_config_find_int(cn, "ignore", 0);
+
 	lvmcache_add_mda(info, device, offset, size, ignore);
+
 	return 1;
 }
 


