From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 22:53:00 -0000
Subject: LVM2 daemons/lvmetad/lvmetad-core.c lib/cache/ ...
Message-ID: <20120301225300.13212.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 22:52:59

Modified files:
	daemons/lvmetad: lvmetad-core.c 
	lib/cache      : lvmetad.c 

Log message:
	Check allocated pointers
	
	Test pointers from allocation against NULL.
	Error paths should be checked, some of them probably need
	some extesions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/28 18:35:06	1.45
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/01 22:52:59	1.46
@@ -89,9 +89,13 @@
 		pthread_mutexattr_t rec;
 		pthread_mutexattr_init(&rec);
 		pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
-		vg = malloc(sizeof(pthread_mutex_t));
+		if (!(vg = malloc(sizeof(pthread_mutex_t))))
+                        return NULL;
 		pthread_mutex_init(vg, &rec);
-		dm_hash_insert(s->lock.vg, id, vg);
+		if (!dm_hash_insert(s->lock.vg, id, vg)) {
+			free(vg);
+			return NULL;
+		}
 	}
 	// debug("lock VG %s\n", id);
 	pthread_mutex_lock(vg);
@@ -101,10 +105,13 @@
 }
 
 static void unlock_vg(lvmetad_state *s, const char *id) {
+	pthread_mutex_t *vg;
+
 	// debug("unlock VG %s\n", id);
 	lock_vgid_to_metadata(s); /* someone might be changing the s->lock.vg structure right
 				   * now, so avoid stepping on each other's toes */
-	pthread_mutex_unlock(dm_hash_lookup(s->lock.vg, id));
+	if ((vg = dm_hash_lookup(s->lock.vg, id)))
+		pthread_mutex_unlock(vg);
 	unlock_vgid_to_metadata(s);
 }
 
@@ -152,9 +159,11 @@
 
 	if (!value && want) {
 		if (!node) {
-			node = dm_config_create_node(cft, field);
+			if (!(node = dm_config_create_node(cft, field)))
+				return 0;
 			node->sib = parent->child;
-			node->v = dm_config_create_value(cft);
+			if (!(node->v = dm_config_create_value(cft)))
+				return 0;
 			node->v->type = DM_CFG_EMPTY_ARRAY;
 			node->parent = parent;
 			parent->child = node;
@@ -177,7 +186,11 @@
 					       struct dm_config_node *parent,
 					       struct dm_config_node *pre_sib)
 {
-	struct dm_config_node *cn = dm_config_create_node(cft, key);
+	struct dm_config_node *cn;
+
+	if (!(cn = dm_config_create_node(cft, key)))
+		return NULL;
+
 	cn->parent = parent;
 	cn->sib = NULL;
 	cn->v = NULL;
@@ -185,7 +198,8 @@
 
 	if (parent && parent->child && !pre_sib) { /* find the last one */
 		pre_sib = parent->child;
-		while (pre_sib && pre_sib->sib) pre_sib = pre_sib->sib;
+		while (pre_sib && pre_sib->sib)
+			pre_sib = pre_sib->sib;
 	}
 
 	if (parent && !parent->child)
@@ -202,8 +216,12 @@
 					     struct dm_config_node *parent,
 					     struct dm_config_node *pre_sib)
 {
-	struct dm_config_node *cn = make_config_node(cft, key, parent, pre_sib);
-	cn->v = dm_config_create_value(cft);
+	struct dm_config_node *cn;
+
+	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
+	    !(cn->v = dm_config_create_value(cft)))
+		return NULL;
+
 	cn->v->type = DM_CFG_STRING;
 	cn->v->v.str = value;
 	return cn;
@@ -216,8 +234,12 @@
 					    struct dm_config_node *parent,
 					    struct dm_config_node *pre_sib)
 {
-	struct dm_config_node *cn = make_config_node(cft, key, parent, pre_sib);
-	cn->v = dm_config_create_value(cft);
+	struct dm_config_node *cn;
+
+	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
+	    !(cn->v = dm_config_create_value(cft)))
+		return NULL;
+
 	cn->v->type = DM_CFG_INT;
 	cn->v->v.i = value;
 	return cn;
@@ -268,12 +290,16 @@
 {
 	struct dm_config_node *pv;
 	int complete = 1;
+	const char *uuid;
+	struct dm_config_tree *pvmeta;
 
 	lock_pvid_to_pvmeta(s);
-	pv = pvs(vg);
-	while (pv) {
-		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
-		struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
+
+	for (pv = pvs(vg); pv; pv = pv->sib) {
+		if (!(uuid = dm_config_find_str(pv->child, "id", NULL)))
+			continue;
+
+		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
 		if (act) {
 			set_flag(cft, pv, "status", "MISSING", !pvmeta);
 			if (pvmeta) {
@@ -289,7 +315,6 @@
 				return complete;
 			}
 		}
-		pv = pv->sib;
 	}
 	unlock_pvid_to_pvmeta(s);
 
@@ -316,7 +341,9 @@
 	}
 
 	/* Nick the pvmeta config tree. */
-	pv = dm_config_clone_node(cft, pvmeta->root, 0);
+	if (!(pv = dm_config_clone_node(cft, pvmeta->root, 0)))
+		return 0;
+
 	if (pre_sib)
 		pre_sib->sib = pv;
 	if (parent && !parent->child)
@@ -340,7 +367,9 @@
 	struct dm_hash_node *n;
 	const char *id;
 	response res = { .buffer = NULL };
-	res.cft = dm_config_create();
+
+	if (!(res.cft = dm_config_create()))
+		return res; /* FIXME error reporting */
 
 	/* The response field */
 	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
@@ -348,11 +377,10 @@
 
 	lock_pvid_to_pvmeta(s);
 
-	n = dm_hash_get_first(s->pvid_to_pvmeta);
-	while (n) {
+	for (n = dm_hash_get_first(s->pvid_to_pvmeta); n;
+	     n = dm_hash_get_next(s->pvid_to_pvmeta, n)) {
 		id = dm_hash_get_key(s->pvid_to_pvmeta, n);
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
-		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
 	}
 
 	unlock_pvid_to_pvmeta(s);
@@ -370,8 +398,11 @@
 	if (!pvid && !devt)
 		return daemon_reply_simple("failed", "reason = %s", "need PVID or device", NULL);
 
-	res.cft = dm_config_create();
-	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
+	if (!(res.cft = dm_config_create()))
+		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+
+	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
+		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && devt)
@@ -404,16 +435,24 @@
 	const char *id;
 	const char *name;
 	response res = { .buffer = NULL };
-	res.cft = dm_config_create();
+	if (!(res.cft = dm_config_create()))
+                goto bad; /* FIXME: better error reporting */
 
 	/* The response field */
 	res.cft->root = cn = dm_config_create_node(res.cft, "response");
+	if (!cn)
+                goto bad; /* FIXME */
 	cn->parent = res.cft->root;
-	cn->v = dm_config_create_value(res.cft);
+	if (!(cn->v = dm_config_create_value(res.cft)))
+		goto bad; /* FIXME */
+
 	cn->v->type = DM_CFG_STRING;
 	cn->v->v.str = "OK";
 
 	cn_vgs = cn = cn->sib = dm_config_create_node(res.cft, "volume_groups");
+	if (!cn_vgs)
+		goto bad; /* FIXME */
+
 	cn->parent = res.cft->root;
 	cn->v = NULL;
 	cn->child = NULL;
@@ -425,7 +464,9 @@
 		id = dm_hash_get_key(s->vgid_to_vgname, n),
 		name = dm_hash_get_data(s->vgid_to_vgname, n);
 
-		cn = dm_config_create_node(res.cft, id);
+		if (!(cn = dm_config_create_node(res.cft, id)))
+			goto bad; /* FIXME */
+
 		if (cn_last)
 			cn_last->sib = cn;
 
@@ -433,10 +474,14 @@
 		cn->sib = NULL;
 		cn->v = NULL;
 
-		cn->child = dm_config_create_node(res.cft, "name");
+		if (!(cn->child = dm_config_create_node(res.cft, "name")))
+			goto bad; /* FIXME */
+
 		cn->child->parent = cn;
 		cn->child->sib = 0;
-		cn->child->v = dm_config_create_value(res.cft);
+		if (!(cn->child->v = dm_config_create_value(res.cft)))
+			goto bad; /* FIXME */
+
 		cn->child->v->type = DM_CFG_STRING;
 		cn->child->v->v.str = name;
 
@@ -448,7 +493,7 @@
 	}
 
 	unlock_vgid_to_metadata(s);
-
+bad:
 	return res;
 }
 
@@ -484,21 +529,26 @@
 	}
 
 	metadata = cft->root;
-	res.cft = dm_config_create();
+	if (!(res.cft = dm_config_create()))
+		goto bad;
 
 	/* The response field */
-	res.cft->root = n = dm_config_create_node(res.cft, "response");
+	if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
+		goto bad;
+
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = "OK";
 
-	n = n->sib = dm_config_create_node(res.cft, "name");
+	if (!(n = n->sib = dm_config_create_node(res.cft, "name")))
+		goto bad;
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = name;
 
 	/* The metadata section */
-	n = n->sib = dm_config_clone_node(res.cft, metadata, 1);
+	if (!(n = n->sib = dm_config_clone_node(res.cft, metadata, 1)))
+		goto bad;
 	n->parent = res.cft->root;
 	res.error = 0;
 	unlock_vg(s, uuid);
@@ -506,6 +556,9 @@
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
 
 	return res;
+bad:
+	unlock_vg(s, uuid);
+	return daemon_reply_simple("failed", "reason = %s", "Out of memory", NULL);
 }
 
 static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
@@ -562,11 +615,12 @@
 static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 			       const char *vgid, int nuke_empty)
 {
-	struct dm_config_node *pv = pvs(vg->root);
+	struct dm_config_node *pv;
 	struct dm_hash_table *to_check;
 	struct dm_hash_node *n;
 	const char *pvid;
 	const char *vgid_old;
+	const char *check_vgid;
 
 	if (!vgid)
 		return 0;
@@ -574,23 +628,27 @@
 	if (!(to_check = dm_hash_create(32)))
 		return 0;
 
-	while (pv) {
-		pvid = dm_config_find_str(pv->child, "id", NULL);
-		vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
-		if (vgid_old && nuke_empty)
-			dm_hash_insert(to_check, vgid_old, (void*) 1);
-		dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid);
+	for (pv = pvs(vg->root); pv; pv = pv->sib) {
+		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
+			continue;
+
+		if (nuke_empty &&
+		    (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
+		    !dm_hash_insert(to_check, vgid_old, (void*) 1))
+			return 0;
+
+		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
+			return 0;
+
 		debug("remap PV %s to VG %s\n", pvid, vgid);
-		pv = pv->sib;
 	}
 
-	n = dm_hash_get_first(to_check);
-	while (n) {
-		const char *check_vgid = dm_hash_get_key(to_check, n);
+	for (n = dm_hash_get_first(to_check); n;
+	     n = dm_hash_get_next(to_check, n)) {
+		check_vgid = dm_hash_get_key(to_check, n);
 		lock_vg(s, check_vgid);
 		vg_remove_if_missing(s, check_vgid);
 		unlock_vg(s, check_vgid);
-		n = dm_hash_get_next(to_check, n);
 	}
 
 	dm_hash_destroy(to_check);
@@ -627,6 +685,8 @@
 {
 	struct dm_config_tree *vg;
 	struct dm_config_node *pv;
+	const char *vgid_check;
+	const char *pvid;
 	int missing = 1;
 
 	if (!vgid)
@@ -635,16 +695,15 @@
 	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, vgid)))
 		return 1;
 
-	pv = pvs(vg->root);
 	lock_pvid_to_pvmeta(s);
-
-	while (pv) {
-		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
-		const char *vgid_check = dm_hash_lookup(s->pvid_to_vgid, pvid);
-		if (dm_hash_lookup(s->pvid_to_pvmeta, pvid) &&
-		    vgid_check && !strcmp(vgid, vgid_check))
+	for (pv = pvs(vg->root); pv; pv = pv->sib) {
+		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
+			continue;
+
+		if ((vgid_check = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
+		    dm_hash_lookup(s->pvid_to_pvmeta, pvid) &&
+		    !strcmp(vgid, vgid_check))
 			missing = 0; /* at least one PV is around */
-		pv = pv->sib;
 	}
 
 	if (missing) {
@@ -670,6 +729,7 @@
 	int haveseq = -1;
 	const char *oldname = NULL;
 	const char *vgid;
+	char *cfgname;
 
 	lock_vgid_to_metadata(s);
 	old = dm_hash_lookup(s->vgid_to_metadata, _vgid);
@@ -709,8 +769,11 @@
 		goto out;
 	}
 
-	cft = dm_config_create();
-	cft->root = dm_config_clone_node(cft, metadata, 0);
+	if (!(cft = dm_config_create()) ||
+	    !(cft->root = dm_config_clone_node(cft, metadata, 0))) {
+		debug("Out of memory\n");
+		goto out;
+	}
 
 	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
@@ -728,16 +791,18 @@
 	}
 
 	lock_vgid_to_metadata(s);
-	dm_hash_insert(s->vgid_to_metadata, vgid, cft);
 	debug("Mapping %s to %s\n", vgid, name);
-	dm_hash_insert(s->vgid_to_vgname, vgid, dm_pool_strdup(dm_config_memory(cft), name));
-	dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid);
+
+	retval = ((cfgname = dm_pool_strdup(dm_config_memory(cft), name)) &&
+		  dm_hash_insert(s->vgid_to_metadata, vgid, cft) &&
+		  dm_hash_insert(s->vgid_to_vgname, vgid, cfgname) &&
+		  dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid)) ? 1 : 0;
 	unlock_vgid_to_metadata(s);
 
-	update_pvid_to_vgid(s, cft, vgid, 1);
+	if (retval)
+		update_pvid_to_vgid(s, cft, vgid, 1);
 
 	unlock_pvid_to_vgid(s);
-	retval = 1;
 out:
 	unlock_vg(s, _vgid);
 	return retval;
@@ -804,11 +869,18 @@
 		dm_hash_remove(s->pvid_to_pvmeta, old);
 	}
 
-	cft = dm_config_create();
-	cft->root = dm_config_clone_node(cft, pvmeta, 0);
+	if (!(cft = dm_config_create()) ||
+	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
+		unlock_pvid_to_pvmeta(s);
+		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+	}
+
 	pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
-	dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
-	dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
+	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
+	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
+		unlock_pvid_to_pvmeta(s);
+		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+	}
 	if (pvmeta_old)
 		dm_config_destroy(pvmeta_old);
 
--- LVM2/lib/cache/lvmetad.c	2012/03/01 20:04:44	1.11
+++ LVM2/lib/cache/lvmetad.c	2012/03/01 22:52:59	1.12
@@ -197,20 +197,20 @@
 		if (!(fid = fmt->ops->create_instance(fmt, &fic)))
 			return_NULL;
 
-		pvcn = dm_config_find_node(top, "metadata/physical_volumes")->child;
-		while (pvcn) {
-			_pv_populate_lvmcache(cmd, pvcn, 0);
-			pvcn = pvcn->sib;
-		}
+		if ((pvcn = dm_config_find_node(top, "metadata/physical_volumes")))
+			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
+				_pv_populate_lvmcache(cmd, pvcn, 0);
 
 		top->key = name;
-		vg = import_vg_from_config_tree(reply.cft, fid);
+		if (!(vg = import_vg_from_config_tree(reply.cft, fid)))
+			return_NULL;
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			if ((info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
 				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
 				pvl->pv->dev = lvmcache_device(info);
-				lvmcache_fid_add_mdas_pv(info, fid);
+				if (!lvmcache_fid_add_mdas_pv(info, fid))
+                                        return_NULL; /* FIXME error path */
 			} /* else probably missing */
 		}
 
@@ -336,8 +336,9 @@
 		return_0;
 	}
 
-	cn = dm_config_find_node(reply.cft->root, "physical_volume");
-	if (!_pv_populate_lvmcache(cmd, cn, 0))
+	if (!(cn = dm_config_find_node(reply.cft->root, "physical_volume")))
+		result = 0;
+        else if (!_pv_populate_lvmcache(cmd, cn, 0))
 		result = 0;
 
 	daemon_reply_destroy(reply);
@@ -361,7 +362,7 @@
 	}
 
 	cn = dm_config_find_node(reply.cft->root, "physical_volume");
-	if (!_pv_populate_lvmcache(cmd, cn, device))
+	if (!cn || !_pv_populate_lvmcache(cmd, cn, device))
 		result = 0;
 
 	daemon_reply_destroy(reply);
@@ -383,11 +384,9 @@
 		return_0;
 	}
 
-	cn = dm_config_find_node(reply.cft->root, "physical_volumes")->child;
-	while (cn) {
-		_pv_populate_lvmcache(cmd, cn, 0);
-		cn = cn->sib;
-	}
+	if ((cn = dm_config_find_node(reply.cft->root, "physical_volumes")))
+		for (cn = cn->child; cn; cn = cn->sib)
+			_pv_populate_lvmcache(cmd, cn, 0);
 
 	daemon_reply_destroy(reply);
 	return 1;
@@ -410,16 +409,18 @@
 		return_0;
 	}
 
-	cn = dm_config_find_node(reply.cft->root, "volume_groups")->child;
-	while (cn) {
-		vgid_txt = cn->key;
-		id_read_format(&vgid, vgid_txt);
-		cn = cn->sib;
-
-		/* the call to lvmetad_vg_lookup will poke the VG into lvmcache */
-		tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
-		release_vg(tmp);
-	}
+	if ((cn = dm_config_find_node(reply.cft->root, "volume_groups")))
+		for (cn = cn->child; cn; cn = cn->sib) {
+			vgid_txt = cn->key;
+			if (!id_read_format(&vgid, vgid_txt)) {
+				stack;
+				continue;
+			}
+
+			/* the call to lvmetad_vg_lookup will poke the VG into lvmcache */
+			tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
+			release_vg(tmp);
+		}
 
 	daemon_reply_destroy(reply);
 	return 1;


