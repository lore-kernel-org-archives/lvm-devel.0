From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:28 +0000 (UTC)
Subject: master - lvmetad: unlock vg on out-of-memory path
Message-ID: <20121215162528.CE737AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4269aadf320f36d3d6fa3a3b66dda98855e7bc3
Commit:        a4269aadf320f36d3d6fa3a3b66dda98855e7bc3
Parent:        788ac7fa547fb98f0edd38685d40b80609f298dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:35:26 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:26 2012 +0100

lvmetad: unlock vg on out-of-memory path

If we fail to get memory for mutex, hash the mutex
or fail somewhere along pthread function calls
return allocated resources back and unlock vg_lock_map mutex.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |   24 ++++++++++++++----------
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e0ce819..dd8ae68 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Unlock vg mutex in error path when lvmetad tries to lock_vg.
   Add check for key string duplication in config_make_nodes_v.
   Add check for created fid in _scan_file.
   Log output also to syslog when abort_on_internal_error is set.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index e1cb583..6c00146 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -121,19 +121,18 @@ static response reply_unknown(const char *reason)
 static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 	struct dm_config_tree *cft;
+	pthread_mutexattr_t rec;
 
 	pthread_mutex_lock(&s->lock.vg_lock_map);
-	vg = dm_hash_lookup(s->lock.vg, id);
-	if (!vg) {
-		pthread_mutexattr_t rec;
-		pthread_mutexattr_init(&rec);
-		pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
-		if (!(vg = malloc(sizeof(pthread_mutex_t))))
-                        return NULL;
-		pthread_mutex_init(vg, &rec);
+	if (!(vg = dm_hash_lookup(s->lock.vg, id))) {
+		if (!(vg = malloc(sizeof(pthread_mutex_t))) ||
+		    pthread_mutexattr_init(&rec) ||
+		    pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP) ||
+		    pthread_mutex_init(vg, &rec))
+			goto bad;
 		if (!dm_hash_insert(s->lock.vg, id, vg)) {
-			free(vg);
-			return NULL;
+			pthread_mutex_destroy(vg);
+			goto bad;
 		}
 	}
 	/* We never remove items from s->lock.vg => the pointer remains valid. */
@@ -147,6 +146,11 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	cft = dm_hash_lookup(s->vgid_to_metadata, id);
 	unlock_vgid_to_metadata(s);
 	return cft;
+bad:
+	pthread_mutex_unlock(&s->lock.vg_lock_map);
+	free(vg);
+	ERROR(s, "Out of memory");
+	return NULL;
 }
 
 static void unlock_vg(lvmetad_state *s, const char *id) {


