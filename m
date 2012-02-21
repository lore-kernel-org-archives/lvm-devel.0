From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Feb 2012 09:19:09 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120221091909.11500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-21 09:19:08

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Tweak lvmetad a bit more:
	- allow at most one PV on any given device
	- allow PV lookup by device
	- merge the pvmeta info into VG metadata when responding to vg_lookup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 17:37:09	1.37
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/21 09:19:08	1.38
@@ -224,6 +224,25 @@
 	vg->sib = NULL; /* Drop any trailing garbage. */
 }
 
+static void merge_pvmeta(struct dm_config_node *pv, struct dm_config_node *pvmeta)
+{
+	if (!pvmeta)
+		return;
+
+	struct dm_config_node *tmp = pvmeta;
+	while (tmp->sib) {
+		/* drop the redundant ID and dev_size nodes */
+		if (!strcmp(tmp->sib->key, "id") || !strcmp(tmp->sib->key, "dev_size"))
+			tmp->sib = tmp->sib->sib;
+		if (!tmp->sib) break;
+		tmp = tmp->sib;
+		tmp->parent = pv;
+	}
+	tmp->sib = pv->child;
+	pv->child = pvmeta;
+	pvmeta->parent = pv;
+}
+
 /* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
  * this function. */
 static int update_pv_status(lvmetad_state *s,
@@ -241,10 +260,9 @@
 		if (act) {
 			set_flag(cft, pv, "status", "MISSING", !pvmeta);
 			if (pvmeta) {
-				// debug_cft("PV META", pvmeta->root);
-				make_int_node(cft, "device",
-					      dm_config_find_int(pvmeta->root, "pvmeta/device", 0),
-					      pv, NULL);
+				struct dm_config_node *pvmeta_cn =
+					dm_config_clone_node(cft, pvmeta->root->child, 1);
+				merge_pvmeta(pv, pvmeta_cn);
 			}
 		}
 		if (!pvmeta) {
@@ -285,6 +303,7 @@
 	if (parent && !parent->child)
 		parent->child = pv;
 	pv->parent = parent;
+	pv->key = pvid;
 
 	/* Add the "variable" bits to it. */
 	struct dm_config_node *cn = NULL;
@@ -318,16 +337,15 @@
 
 	unlock_pvid_to_pvmeta(s);
 
-	// debug_cft("PV LIST", res.cft->root);
-
 	return res;
 }
 
 static response pv_lookup(lvmetad_state *s, request r)
 {
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
-	if (!pvid)
-		return daemon_reply_simple("failed", "reason = %s", "need PVID", NULL);
+	int64_t devt = daemon_request_int(r, "device", 0);
+	if (!pvid && !devt)
+		return daemon_reply_simple("failed", "reason = %s", "need PVID or device", NULL);
 
 	response res = { .buffer = NULL };
 	res.cft = dm_config_create();
@@ -336,6 +354,15 @@
 	struct dm_config_node *pv;
 
 	lock_pvid_to_pvmeta(s);
+	if (!pvid && devt)
+		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
+
+	if (!pvid) {
+		debug("pv_lookup: could not find device %lld\n", devt);
+		unlock_pvid_to_pvmeta(s);
+		return daemon_reply_simple("failed", "reason = %s", "device not found", NULL);
+	}
+
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
 		unlock_pvid_to_pvmeta(s);
@@ -345,8 +372,6 @@
 	pv->key = "physical_volume";
 	unlock_pvid_to_pvmeta(s);
 
-	// debug_cft("PV LOOKUP", res.cft->root);
-
 	return res;
 }
 
@@ -455,8 +480,6 @@
 
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
 
-	// debug_cft("METADATA", n);
-
 	return res;
 }
 
@@ -673,7 +696,6 @@
 		remove_metadata(s, vgid, 1);
 	}
 
-	// debug_cft("METADATA", metadata);
 	lock_vgid_to_metadata(s);
 	dm_hash_insert(s->vgid_to_metadata, vgid, cft);
 	debug("Mapping %s to %s\n", vgid, name);
@@ -697,7 +719,6 @@
 	int64_t device = daemon_request_int(r, "device", 0);
 
 	debug("pv_gone: %s / %lld\n", pvid, device);
-	debug_cft("PV_GONE", r.cft->root);
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && device > 0)
@@ -733,8 +754,6 @@
 
 	int complete = 0, orphan = 0;
 
-	// debug_cft("INCOMING PV", r.cft->root);
-
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 	if (!pvmeta)
@@ -747,6 +766,10 @@
 
 	lock_pvid_to_pvmeta(s);
 	{
+		const char *old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
+		if (old)
+			dm_hash_remove(s->pvid_to_pvmeta, old);
+
 		struct dm_config_tree *cft = dm_config_create();
 		cft->root = dm_config_clone_node(cft, pvmeta, 0);
 		const char *pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
@@ -758,7 +781,7 @@
 	if (metadata) {
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
-		debug("obtained vgid = %s, vgname = %s", vgid, vgname);
+		debug("obtained vgid = %s, vgname = %s\n", vgid, vgname);
 		if (!vgname)
 			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)


