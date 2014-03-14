From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 14 Mar 2014 09:10:29 +0000 (UTC)
Subject: master - lvmetad: Fix pvmeta_old_{pvid, dev} logic when they are the same.
Message-ID: <20140314091029.E077B60E51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=551b6b799867860fc6a437be5298bc74b814ab19
Commit:        551b6b799867860fc6a437be5298bc74b814ab19
Parent:        67c539f346a8259a4100ab10196486f8793fecce
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Mar 14 10:06:27 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Mar 14 10:09:16 2014 +0100

lvmetad: Fix pvmeta_old_{pvid,dev} logic when they are the same.

---
 daemons/lvmetad/lvmetad-core.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1b093cc..1858ee2 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -883,22 +883,22 @@ static response pv_found(lvmetad_state *s, request r)
 
 	lock_pvid_to_pvmeta(s);
 
+	if ((pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
+		dm_config_get_uint64(pvmeta_old_pvid->root, "pvmeta/device", &device_old_pvid);
+
 	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
 		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
 		vgid_old = dm_hash_lookup(s->pvid_to_vgid, old);
 	}
 
-	if ((pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
-		dm_config_get_uint64(pvmeta_old_pvid->root, "pvmeta/device", &device_old_pvid);
-
 	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 " (previously %" PRIu64 "), old = %s",
 		 pvid, vgid, device, device_old_pvid, old);
 
 	if (!(cft->root = dm_config_clone_node(cft, pvmeta, 0)))
                 goto out_of_mem;
 
-	if (pvmeta_old_pvid && compare_config(pvmeta_old_pvid->root, cft->root))
+	if (!pvmeta_old_pvid || compare_config(pvmeta_old_pvid->root, cft->root))
 		changed |= 1;
 
 	if (pvmeta_old_pvid && device != device_old_pvid) {


