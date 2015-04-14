From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Apr 2015 20:22:09 +0000 (UTC)
Subject: master - lvmetad: Track alternate devices for PVs.
Message-ID: <20150414202209.5CA3560D72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1dd61459cf40eae21ed407115f652cabdba1ad4
Commit:        a1dd61459cf40eae21ed407115f652cabdba1ad4
Parent:        2ebb4f4ca3a9e36969007851c7be20c5dc4d85a0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Mar 31 18:42:17 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 14 20:18:27 2015 +0200

lvmetad: Track alternate devices for PVs.

There are two reasons for this: first, this allows the client side to notice
that some PV has multiple devices associated with it and print appropriate
warnings. Second, if a duplicate device pops up and disappears, after this
change the original connection between the PV and device is not lost.
---
 daemons/lvmetad/lvmetad-core.c |  101 ++++++++++++++++++++++++++++++---------
 1 files changed, 77 insertions(+), 24 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 693eb86..1a2ce44 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -68,9 +68,6 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_destroy(s->vgid_to_vgname);
 	dm_hash_destroy(s->vgname_to_vgid);
 
-	dm_hash_iterate(n, s->device_to_pvid)
-		dm_free(dm_hash_get_data(s->device_to_pvid, n));
-
 	dm_hash_destroy(s->device_to_pvid);
 	dm_hash_destroy(s->pvid_to_vgid);
 }
@@ -773,11 +770,46 @@ out: /* FIXME: We should probably abort() on partial failures. */
 	return retval;
 }
 
+static dev_t device_remove(lvmetad_state *s, struct dm_config_tree *pvmeta, dev_t device)
+{
+	struct dm_config_node *pvmeta_tmp;
+	struct dm_config_value *v = NULL;
+	dev_t alt_device = 0, prim_device = 0;
+
+	if ((pvmeta_tmp = dm_config_find_node(pvmeta->root, "pvmeta/devices_alternate")))
+		v = pvmeta_tmp->v;
+
+	prim_device = dm_config_find_int64(pvmeta->root, "pvmeta/device", 0);
+
+	/* it is the primary device */
+	if (device > 0 && device == prim_device && pvmeta_tmp && pvmeta_tmp->v)
+	{
+		alt_device = pvmeta_tmp->v->v.i;
+		pvmeta_tmp->v = pvmeta_tmp->v->next;
+		pvmeta_tmp = dm_config_find_node(pvmeta->root, "pvmeta/device");
+		pvmeta_tmp->v->v.i = alt_device;
+	} else if (device != prim_device)
+		alt_device = prim_device;
+
+	/* it is an alternate device */
+	if (device > 0 && v && v->v.i == device)
+		pvmeta_tmp->v = v->next;
+	else while (device > 0 && pvmeta_tmp && v) {
+		if (v->next && v->next->v.i == device)
+			v->next = v->next->next;
+		v = v->next;
+	}
+
+	return alt_device;
+}
+
 static response pv_gone(lvmetad_state *s, request r)
 {
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t device = daemon_request_int(r, "device", 0);
+	int64_t alt_device = 0;
 	struct dm_config_tree *pvmeta;
+	struct dm_config_node *pvmeta_tmp;
 	char *pvid_old, *vgid;
 
 	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
@@ -797,10 +829,13 @@ static response pv_gone(lvmetad_state *s, request r)
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
-	dm_hash_remove(s->pvid_to_pvmeta, pvid);
-	unlock_pvid_to_pvmeta(s);
 
-	dm_free(pvid_old);
+	if (!(alt_device = device_remove(s, pvmeta, device)))
+		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+
+	DEBUGLOG(s, "pv_gone alt_device = %" PRIu64, alt_device);
+
+	unlock_pvid_to_pvmeta(s);
 
 	if (vgid) {
 		if (!(vgid = dm_strdup(vgid)))
@@ -815,9 +850,15 @@ static response pv_gone(lvmetad_state *s, request r)
 	if (!pvmeta)
 		return reply_unknown("PVID does not exist");
 
-	dm_config_destroy(pvmeta);
+	if (!alt_device)
+		dm_config_destroy(pvmeta);
 
-	return daemon_reply_simple("OK", NULL);
+	if (alt_device) {
+		return daemon_reply_simple("OK",
+					   "device = %"PRId64, alt_device,
+					   NULL);
+	} else
+		return daemon_reply_simple("OK", NULL );
 }
 
 static response pv_clear_all(lvmetad_state *s, request r)
@@ -845,11 +886,11 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	const char *vgid_old = NULL;
-	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
+	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta"), *altdev = NULL;
+	struct dm_config_value *altdev_v;
 	uint64_t device, device_old_pvid = 0;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
 	char *old;
-	char *pvid_dup;
 	int complete = 0, orphan = 0;
 	int64_t seqno = -1, seqno_old = -1, changed = 0;
 
@@ -861,12 +902,8 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
 		return reply_fail("need PV device number");
 
-	if (!(cft = dm_config_create()) ||
-	    (!(pvid_dup = dm_strdup(pvid)))) {
-		if (cft)
-			dm_config_destroy(cft);
+	if (!(cft = dm_config_create()))
 		return reply_fail("out of memory");
-	}
 
 	lock_pvid_to_pvmeta(s);
 
@@ -875,7 +912,6 @@ static response pv_found(lvmetad_state *s, request r)
 
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
 		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
-		dm_hash_remove(s->pvid_to_pvmeta, old);
 		vgid_old = dm_hash_lookup(s->pvid_to_vgid, old);
 	}
 
@@ -885,35 +921,52 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!(cft->root = dm_config_clone_node(cft, pvmeta, 0)))
                 goto out_of_mem;
 
+	pvid = dm_config_find_str(cft->root, "pvmeta/id", NULL);
+
 	if (!pvmeta_old_pvid || compare_config(pvmeta_old_pvid->root, cft->root))
 		changed |= 1;
 
 	if (pvmeta_old_pvid && device != device_old_pvid) {
-		DEBUGLOG(s, "pv %s no longer on device %" PRIu64, pvid, device_old_pvid);
-		dm_free(dm_hash_lookup_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid)));
+		DEBUGLOG(s, "PV %s duplicated on device %" PRIu64, pvid, device_old_pvid);
 		dm_hash_remove_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid));
+		if (!dm_hash_insert_binary(s->device_to_pvid, &device_old_pvid,
+					   sizeof(device_old_pvid), (void*)pvid))
+			goto out_of_mem;
+		if ((altdev = dm_config_find_node(pvmeta_old_pvid->root, "pvmeta/devices_alternate"))) {
+			altdev = dm_config_clone_node(cft, altdev, 0);
+			chain_node(altdev, cft->root, 0);
+		} else
+			altdev = make_config_node(cft, "devices_alternate", cft->root, 0);
+		if (!altdev || !(altdev_v = dm_config_create_value(cft)))
+			goto out_of_mem;
+		altdev_v->next = altdev->v;
+		altdev->v = altdev_v;
+		altdev->v->v.i = device_old_pvid;
 		changed |= 1;
 	}
 
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
-	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
+	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid)) {
 		dm_hash_remove(s->pvid_to_pvmeta, pvid);
 out_of_mem:
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(cft);
-		dm_free(pvid_dup);
 		dm_free(old);
 		return reply_fail("out of memory");
 	}
 
 	unlock_pvid_to_pvmeta(s);
 
-	dm_free(old);
-
 	if (pvmeta_old_pvid)
 		dm_config_destroy(pvmeta_old_pvid);
-	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid)
-		dm_config_destroy(pvmeta_old_dev);
+	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid) {
+		dev_t d = dm_config_find_int64(pvmeta_old_dev->root, "pvmeta/device", 0);
+		WARN(s, "pv_found: stray device %"PRId64, d);
+		if (!device_remove(s, pvmeta_old_dev, device)) {
+			dm_hash_remove(s->pvid_to_pvmeta, old);
+			dm_config_destroy(pvmeta_old_dev);
+		}
+	}
 
 	if (metadata) {
 		if (!vgid)


