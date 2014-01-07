From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Jan 2014 02:32:05 +0000 (UTC)
Subject: master - lvmetad: Flush a VG if it goes completely missing due to pv_found.
Message-ID: <20140107023205.972BD600D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a832120521ea4cd528b8228bf0fe1cf80fa603e9
Commit:        a832120521ea4cd528b8228bf0fe1cf80fa603e9
Parent:        89e7d81d92274ed60b73332e04ceb966e398a0e6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jan 7 03:28:20 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jan 7 03:28:20 2014 +0100

lvmetad: Flush a VG if it goes completely missing due to pv_found.

---
 daemons/lvmetad/lvmetad-core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7409839..19e0b6b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -859,6 +859,7 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *pvid = daemon_request_str(r, "pvmeta/id", NULL);
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
+	const char *vgid_old;
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
@@ -880,6 +881,12 @@ static response pv_found(lvmetad_state *s, request r)
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
 		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
+
+		if (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) {
+			lock_vg(s, vgid_old);
+			vg_remove_if_missing(s, vgid_old, 1);
+			unlock_vg(s, vgid_old);
+		}
 	}
 	pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 


