From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  8 Oct 2012 10:10:00 +0000 (UTC)
Subject: master - lvmetad: Avoid overlapping locks that could cause a deadlock (BZ 862253).
Message-ID: <20121008101000.AA7CA9FBD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e312c56adb04e709819868c6fa89f5984013a65
Commit:        6e312c56adb04e709819868c6fa89f5984013a65
Parent:        0dfafd77d4c5682ac9ee37f3a2a4dce92659187c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 09:12:51 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 09:12:51 2012 +0200

lvmetad: Avoid overlapping locks that could cause a deadlock (BZ 862253).

---
 daemons/lvmetad/lvmetad-core.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0c39a77..dce7535 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -38,6 +38,7 @@ typedef struct {
 	struct dm_hash_table *pvid_to_vgid;
 	struct {
 		struct dm_hash_table *vg;
+		pthread_mutex_t vg_lock_map;
 		pthread_mutex_t pvid_to_pvmeta;
 		pthread_mutex_t vgid_to_metadata;
 		pthread_mutex_t pvid_to_vgid;
@@ -112,7 +113,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 	struct dm_config_tree *cft;
 
-	lock_vgid_to_metadata(s);
+	pthread_mutex_lock(&s->lock.vg_lock_map);
 	vg = dm_hash_lookup(s->lock.vg, id);
 	if (!vg) {
 		pthread_mutexattr_t rec;
@@ -126,8 +127,14 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 			return NULL;
 		}
 	}
+	/* We never remove items from s->lock.vg => the pointer remains valid. */
+	pthread_mutex_unlock(&s->lock.vg_lock_map);
+
 	DEBUG(s, "locking VG %s", id);
 	pthread_mutex_lock(vg);
+
+	/* Protect against structure changes of the vgid_to_metadata hash. */
+	lock_vgid_to_metadata(s);
 	cft = dm_hash_lookup(s->vgid_to_metadata, id);
 	unlock_vgid_to_metadata(s);
 	return cft;
@@ -137,11 +144,11 @@ static void unlock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 
 	DEBUG(s, "unlocking VG %s", id);
-	lock_vgid_to_metadata(s); /* someone might be changing the s->lock.vg structure right
-				   * now, so avoid stepping on each other's toes */
+	/* Protect the s->lock.vg structure from concurrent access. */
+	pthread_mutex_lock(&s->lock.vg_lock_map);
 	if ((vg = dm_hash_lookup(s->lock.vg, id)))
 		pthread_mutex_unlock(vg);
-	unlock_vgid_to_metadata(s);
+	pthread_mutex_unlock(&s->lock.vg_lock_map);
 }
 
 static struct dm_config_node *pvs(struct dm_config_node *vg)
@@ -975,6 +982,7 @@ static int init(daemon_state *s)
 	pthread_mutex_init(&ls->lock.pvid_to_pvmeta, &rec);
 	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
+	pthread_mutex_init(&ls->lock.vg_lock_map, NULL);
 	pthread_mutex_init(&ls->token_lock, NULL);
 	create_metadata_hashes(ls);
 


