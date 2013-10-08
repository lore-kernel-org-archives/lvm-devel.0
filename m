From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  8 Oct 2013 21:49:27 +0000 (UTC)
Subject: master - lvmetad: Properly grab locks in pv_gone.
Message-ID: <20131008214927.2F84D6146A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d888a0557efc173336582ca94055e0630d5ceca8
Commit:        d888a0557efc173336582ca94055e0630d5ceca8
Parent:        805f7e404202300422b9533453ab722d0503fb69
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 8 23:16:41 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 8 23:21:09 2013 +0200

lvmetad: Properly grab locks in pv_gone.

---
 daemons/lvmetad/lvmetad-core.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1593bf7..cfbf279 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -796,11 +796,23 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
+	const char *vgid = dm_strdup(dm_hash_lookup(s->pvid_to_vgid, pvid));
+
+	if (!vgid) {
+		unlock_pvid_to_pvmeta(s);
+		return reply_fail("out of memory");
+	}
+
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
-	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid), 1);
 	unlock_pvid_to_pvmeta(s);
 
+	lock_vg(s, vgid);
+	vg_remove_if_missing(s, vgid, 1);
+	unlock_vg(s, vgid);
+
+	dm_free(vgid);
+
 	if (pvid_old)
 		dm_free(pvid_old);
 


