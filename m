From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 16 Dec 2012 23:54:28 +0000 (UTC)
Subject: master - lvmetad: Fix a possible race in remove_metadata.
Message-ID: <20121216235428.1EEE81292@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5294a6f77a900493b3e81eb70c1698ec3c4814b8
Commit:        5294a6f77a900493b3e81eb70c1698ec3c4814b8
Parent:        fae1a611d2f907aa23c237b9f84df5089d30f728
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Dec 17 00:43:18 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Dec 17 00:47:55 2012 +0100

lvmetad: Fix a possible race in remove_metadata.

All operations on shared hash tables need to be protected by mutexes. Moreover,
lookup and subsequent key removal need to happen atomically, to avoid races (and
possible double free-ing) between multiple threads trying to manipulate the same
VG.
---
 daemons/lvmetad/lvmetad-core.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 674ddea..a951b30 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -601,19 +601,23 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	lock_vgid_to_metadata(s);
 	old = dm_hash_lookup(s->vgid_to_metadata, vgid);
 	oldname = dm_hash_lookup(s->vgid_to_vgname, vgid);
-	unlock_vgid_to_metadata(s);
 
-	if (!old)
+	if (!old) {
+		unlock_vgid_to_metadata(s);
 		return 0;
+	}
+
 	assert(oldname);
 
-	if (update_pvids)
-		/* FIXME: What should happen when update fails */
-		update_pvid_to_vgid(s, old, "#orphan", 0);
 	/* need to update what we have since we found a newer version */
 	dm_hash_remove(s->vgid_to_metadata, vgid);
 	dm_hash_remove(s->vgid_to_vgname, vgid);
 	dm_hash_remove(s->vgname_to_vgid, oldname);
+	unlock_vgid_to_metadata(s);
+
+	if (update_pvids)
+		/* FIXME: What should happen when update fails */
+		update_pvid_to_vgid(s, old, "#orphan", 0);
 	dm_config_destroy(old);
 	return 1;
 }


