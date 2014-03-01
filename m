From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Mar 2014 13:24:44 +0000 (UTC)
Subject: master - lvmetad: move memalloc/free out of lock
Message-ID: <20140301132444.9DC7F60C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bda98c4b8dcd17d27c582fe6e2bc2d3c2742d4d7
Commit:        bda98c4b8dcd17d27c582fe6e2bc2d3c2742d4d7
Parent:        d8513da9be5c061a85ab35d7d35ad937e8130490
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 1 11:38:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 1 14:08:58 2014 +0100

lvmetad: move memalloc/free out of lock

Small code move to lower locking time and make memory
allocation and free outside of lock.

Drop duplicate test of NULL pointer before calling dm_free.
---
 daemons/lvmetad/lvmetad-core.c |   56 ++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index bf0892b..f1fb749 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -344,8 +344,8 @@ static response pv_lookup(lvmetad_state *s, request r)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
 
 	if (!pvid) {
-		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
 		unlock_pvid_to_pvmeta(s);
+		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
 		dm_config_destroy(res.cft);
 		return reply_unknown("device not found");
 	}
@@ -809,30 +809,28 @@ static response pv_gone(lvmetad_state *s, request r)
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
-	if (vgid && !(vgid = dm_strdup(vgid))) {
-		unlock_pvid_to_pvmeta(s);
-		return reply_fail("out of memory");
-	}
-
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	unlock_pvid_to_pvmeta(s);
 
+	dm_free(pvid_old);
+
 	if (vgid) {
+		if (!(vgid = dm_strdup(vgid)))
+			return reply_fail("out of memory");
+
 		lock_vg(s, vgid);
 		vg_remove_if_missing(s, vgid, 1);
 		unlock_vg(s, vgid);
 		dm_free(vgid);
 	}
 
-	if (pvid_old)
-		dm_free(pvid_old);
-
-	if (pvmeta) {
-		dm_config_destroy(pvmeta);
-		return daemon_reply_simple("OK", NULL);
-	} else
+	if (!pvmeta)
 		return reply_unknown("PVID does not exist");
+
+	dm_config_destroy(pvmeta);
+
+	return daemon_reply_simple("OK", NULL);
 }
 
 static response pv_clear_all(lvmetad_state *s, request r)
@@ -876,6 +874,13 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
 		return reply_fail("need PV device number");
 
+	if (!(cft = dm_config_create()) ||
+	    (!(pvid_dup = dm_strdup(pvid)))) {
+		if (cft)
+			dm_config_destroy(cft);
+		return reply_fail("out of memory");
+	}
+
 	lock_pvid_to_pvmeta(s);
 
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
@@ -890,21 +895,8 @@ static response pv_found(lvmetad_state *s, request r)
 	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 " (previously %" PRIu64 "), old = %s",
 		 pvid, vgid, device, device_old_pvid, old);
 
-	dm_free(old);
-
-	if (!(cft = dm_config_create()) ||
-	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
-		unlock_pvid_to_pvmeta(s);
-		if (cft)
-			dm_config_destroy(cft);
-		return reply_fail("out of memory");
-	}
-
-	if (!(pvid_dup = dm_strdup(pvid))) {
-		unlock_pvid_to_pvmeta(s);
-		dm_config_destroy(cft);
-		return reply_fail("out of memory");
-	}
+	if (!(cft->root = dm_config_clone_node(cft, pvmeta, 0)))
+                goto out_of_mem;
 
 	if (pvmeta_old_pvid && device != device_old_pvid) {
 		DEBUGLOG(s, "pv %s no longer on device %" PRIu64, pvid, device_old_pvid);
@@ -915,19 +907,23 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
 		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+out_of_mem:
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(cft);
 		dm_free(pvid_dup);
+		dm_free(old);
 		return reply_fail("out of memory");
 	}
 
+	unlock_pvid_to_pvmeta(s);
+
+	dm_free(old);
+
 	if (pvmeta_old_pvid)
 		dm_config_destroy(pvmeta_old_pvid);
 	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid)
 		dm_config_destroy(pvmeta_old_dev);
 
-	unlock_pvid_to_pvmeta(s);
-
 	if (metadata) {
 		if (!vgid)
 			return reply_fail("need VG UUID");


