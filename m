From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:53:06 +0000 (UTC)
Subject: master - lvmetad: Fix a leak on duplicated PVs (same PVID, different device).
Message-ID: <20121009055306.A29D7241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06243be91b12a7bb249d2b18cf5eeb0492ccfa4f
Commit:        06243be91b12a7bb249d2b18cf5eeb0492ccfa4f
Parent:        665b6b308e4482a33fc5dd67e1e12066515e1424
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:31:12 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 01:38:58 2012 +0200

lvmetad: Fix a leak on duplicated PVs (same PVID, different device).

---
 daemons/lvmetad/lvmetad-core.c |   33 +++++++++++++++++++++++++--------
 1 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 466042b..4741649 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -66,6 +66,13 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_destroy(s->vgid_to_metadata);
 	dm_hash_destroy(s->vgid_to_vgname);
 	dm_hash_destroy(s->vgname_to_vgid);
+
+	n = dm_hash_get_first(s->device_to_pvid);
+	while (n) {
+		dm_free(dm_hash_get_data(s->device_to_pvid, n));
+		n = dm_hash_get_next(s->device_to_pvid, n);
+	}
+
 	dm_hash_destroy(s->device_to_pvid);
 	dm_hash_destroy(s->pvid_to_vgid);
 }
@@ -748,6 +755,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t device = daemon_request_int(r, "device", 0);
 	struct dm_config_tree *pvmeta;
+	char *pvid_old;
 
 	DEBUG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
@@ -762,11 +770,15 @@ static response pv_gone(lvmetad_state *s, request r)
 	DEBUG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
 	unlock_pvid_to_pvmeta(s);
 
+	if (pvid_old)
+		dm_free(pvid_old);
+
 	if (pvmeta) {
 		dm_config_destroy(pvmeta);
 		return daemon_reply_simple("OK", NULL);
@@ -800,8 +812,8 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
-	struct dm_config_tree *cft, *pvmeta_old = NULL;
-	const char *old;
+	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
+	char *old;
 	const char *pvid_dup;
 	int complete = 0, orphan = 0;
 	int64_t seqno = -1, seqno_old = -1;
@@ -814,14 +826,17 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
 		return reply_fail("need PV device number");
 
-	DEBUG(s, "pv_found %s, vgid = %s, device = %" PRIu64, pvid, vgid, device);
-
 	lock_pvid_to_pvmeta(s);
 
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
-		pvmeta_old = dm_hash_lookup(s->pvid_to_pvmeta, old);
+		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
 	}
+	pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+
+	DEBUG(s, "pv_found %s, vgid = %s, device = %" PRIu64 ", old = %s", pvid, vgid, device, old);
+
+	dm_free(old);
 
 	if (!(cft = dm_config_create()) ||
 	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
@@ -829,14 +844,16 @@ static response pv_found(lvmetad_state *s, request r)
 		return reply_fail("out of memory");
 	}
 
-	pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
+	pvid_dup = dm_strdup(pvid);
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
 		unlock_pvid_to_pvmeta(s);
 		return reply_fail("out of memory");
 	}
-	if (pvmeta_old)
-		dm_config_destroy(pvmeta_old);
+	if (pvmeta_old_pvid)
+		dm_config_destroy(pvmeta_old_pvid);
+	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid)
+		dm_config_destroy(pvmeta_old_dev);
 
 	unlock_pvid_to_pvmeta(s);
 


