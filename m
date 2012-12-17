From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Dec 2012 12:51:20 +0000 (UTC)
Subject: master - Revert "lvmetad: simplify pvid memory allocation."
Message-ID: <20121217125120.CB108A0DE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69099e7ef57eb2d39da836a5466196ec05123ffb
Commit:        69099e7ef57eb2d39da836a5466196ec05123ffb
Parent:        5294a6f77a900493b3e81eb70c1698ec3c4814b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 17 13:49:19 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 13:49:19 2012 +0100

Revert "lvmetad: simplify pvid memory allocation."

This reverts commit ed23da95b63308e11f8d680b189686a5d2d380d0.

Hash table device_to_pvid  seems to contain references to
already deleted pvids and so revert to the older
behaviour using allocated memory.
---
 daemons/lvmetad/lvmetad-core.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index a951b30..cbd6b09 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -67,6 +67,13 @@ static void destroy_metadata_hashes(lvmetad_state *s)
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
@@ -765,6 +772,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t device = daemon_request_int(r, "device", 0);
 	struct dm_config_tree *pvmeta;
+	char *pvid_old;
 
 	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
@@ -779,11 +787,15 @@ static response pv_gone(lvmetad_state *s, request r)
 	DEBUGLOG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
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
@@ -818,8 +830,8 @@ static response pv_found(lvmetad_state *s, request r)
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
-	const char *old;
-	const char *pvid_dup;
+	char *old;
+	char *pvid_dup;
 	int complete = 0, orphan = 0;
 	int64_t seqno = -1, seqno_old = -1;
 
@@ -841,6 +853,8 @@ static response pv_found(lvmetad_state *s, request r)
 
 	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 ", old = %s", pvid, vgid, device, old);
 
+	dm_free(old);
+
 	if (!(cft = dm_config_create()) ||
 	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
 		unlock_pvid_to_pvmeta(s);
@@ -849,7 +863,7 @@ static response pv_found(lvmetad_state *s, request r)
 		return reply_fail("out of memory");
 	}
 
-	if (!(pvid_dup = dm_pool_strdup(dm_config_memory(cft), pvid))) {
+	if (!(pvid_dup = dm_strdup(pvid))) {
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(cft);
 		return reply_fail("out of memory");
@@ -860,6 +874,7 @@ static response pv_found(lvmetad_state *s, request r)
 		unlock_pvid_to_pvmeta(s);
 		dm_hash_remove(s->pvid_to_pvmeta, pvid);
 		dm_config_destroy(cft);
+		dm_free(pvid_dup);
 		return reply_fail("out of memory");
 	}
 	if (pvmeta_old_pvid)


