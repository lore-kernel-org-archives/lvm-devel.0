From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 12:58:10 +0000 (UTC)
Subject: master - lvmetad: Do not try to lock a NULL vgid.
Message-ID: <20131009125810.7A35860D50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcb44281b7c379ed3310b5f9a16ce380d84f31dc
Commit:        bcb44281b7c379ed3310b5f9a16ce380d84f31dc
Parent:        17f3b8280b8ade397a6a4a8fd82ba7dd7d0e1d1b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 14:53:58 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 9 14:56:06 2013 +0200

lvmetad: Do not try to lock a NULL vgid.

---
 daemons/lvmetad/lvmetad-core.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index b7a3023..ed44def 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -796,9 +796,9 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-	char *vgid = dm_strdup(dm_hash_lookup(s->pvid_to_vgid, pvid));
+	const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
-	if (!vgid) {
+	if (vgid && !(vgid = dm_strdup(vgid))) {
 		unlock_pvid_to_pvmeta(s);
 		return reply_fail("out of memory");
 	}
@@ -807,11 +807,12 @@ static response pv_gone(lvmetad_state *s, request r)
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	unlock_pvid_to_pvmeta(s);
 
-	lock_vg(s, vgid);
-	vg_remove_if_missing(s, vgid, 1);
-	unlock_vg(s, vgid);
-
-	dm_free(vgid);
+	if (vgid) {
+		lock_vg(s, vgid);
+		vg_remove_if_missing(s, vgid, 1);
+		unlock_vg(s, vgid);
+		dm_free(vgid);
+	}
 
 	if (pvid_old)
 		dm_free(pvid_old);


