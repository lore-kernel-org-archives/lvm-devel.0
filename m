From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  8 Oct 2013 21:49:25 +0000 (UTC)
Subject: master - lvmetad: Clean up pvid->vgid map when last PV in a VG disappears.
Message-ID: <20131008214925.13EF36146A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=805f7e404202300422b9533453ab722d0503fb69
Commit:        805f7e404202300422b9533453ab722d0503fb69
Parent:        830d233b1750d3fa885f75e488f18c91e98d61e5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 8 23:14:55 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 8 23:21:09 2013 +0200

lvmetad: Clean up pvid->vgid map when last PV in a VG disappears.

---
 daemons/lvmetad/lvmetad-core.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index e1ec5a8..1593bf7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -551,7 +551,7 @@ static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
 	return result;
 }
 
-static int vg_remove_if_missing(lvmetad_state *s, const char *vgid);
+static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids);
 
 /* You need to be holding the pvid_to_vgid lock already to call this. */
 static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
@@ -590,7 +590,7 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 	     n = dm_hash_get_next(to_check, n)) {
 		check_vgid = dm_hash_get_key(to_check, n);
 		lock_vg(s, check_vgid);
-		vg_remove_if_missing(s, check_vgid);
+		vg_remove_if_missing(s, check_vgid, 0);
 		unlock_vg(s, check_vgid);
 	}
 
@@ -631,7 +631,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 }
 
 /* The VG must be locked. */
-static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
+static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids)
 {
 	struct dm_config_tree *vg;
 	struct dm_config_node *pv;
@@ -658,7 +658,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
 
 	if (missing) {
 		DEBUGLOG(s, "removing empty VG %s", vgid);
-		remove_metadata(s, vgid, 0);
+		remove_metadata(s, vgid, update_pvids);
 	}
 
 	unlock_pvid_to_pvmeta(s);
@@ -798,7 +798,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
-	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
+	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid), 1);
 	unlock_pvid_to_pvmeta(s);
 
 	if (pvid_old)


