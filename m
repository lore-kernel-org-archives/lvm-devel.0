From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Jan 2014 14:25:18 +0000 (UTC)
Subject: master - lvmetad: Fix getting vgid_old & avoid removing in-transition VGs.
Message-ID: <20140108142518.E2793610B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a8e59fb5afd1f85be5cb96744b3eb34ad9a5e71
Commit:        8a8e59fb5afd1f85be5cb96744b3eb34ad9a5e71
Parent:        2b7f7d0ab488f4f179100e91223788fe268299be
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 8 14:54:26 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 8 15:22:24 2014 +0100

lvmetad: Fix getting vgid_old & avoid removing in-transition VGs.

---
 daemons/lvmetad/lvmetad-core.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0659c9d..eefbf1d 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -859,7 +859,7 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *pvid = daemon_request_str(r, "pvmeta/id", NULL);
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
-	const char *vgid_old;
+	const char *vgid_old = NULL;
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
@@ -881,12 +881,7 @@ static response pv_found(lvmetad_state *s, request r)
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
 		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
-
-		if ((vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid))) {
-			lock_vg(s, vgid_old);
-			vg_remove_if_missing(s, vgid_old, 1);
-			unlock_vg(s, vgid_old);
-		}
+		vgid_old = dm_hash_lookup(s->pvid_to_vgid, old);
 	}
 	pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 
@@ -953,6 +948,12 @@ static response pv_found(lvmetad_state *s, request r)
 		unlock_vg(s, vgid);
 	}
 
+	if (vgid_old && (!vgid || strcmp(vgid, vgid_old))) {
+		lock_vg(s, vgid_old);
+		vg_remove_if_missing(s, vgid_old, 1);
+		unlock_vg(s, vgid_old);
+	}
+
 	return daemon_reply_simple("OK",
 				   "status = %s", orphan ? "orphan" :
 				                     (complete ? "complete" : "partial"),


