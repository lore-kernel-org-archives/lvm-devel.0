From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Oct 2012 13:21:00 +0000 (UTC)
Subject: master - lvmetad: rename DEBUG() to DEBUGLOG()
Message-ID: <20121015132100.A89BFAABB2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8290de964fbf0e6dcb9622f2e234a1bd794ea2e2
Commit:        8290de964fbf0e6dcb9622f2e234a1bd794ea2e2
Parent:        895ee616425215136ec346d4637d2887add27913
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 15 14:20:11 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 15 14:20:11 2012 +0100

lvmetad: rename DEBUG() to DEBUGLOG()

DEBUG is already defined by -DDEBUG
---
 daemons/lvmetad/lvmetad-core.c |   42 ++++++++++++++++++++--------------------
 libdaemon/server/daemon-log.h  |    9 +------
 2 files changed, 23 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ebb8bc3..0a1c884 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -139,7 +139,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	/* We never remove items from s->lock.vg => the pointer remains valid. */
 	pthread_mutex_unlock(&s->lock.vg_lock_map);
 
-	DEBUG(s, "locking VG %s", id);
+	DEBUGLOG(s, "locking VG %s", id);
 	pthread_mutex_lock(vg);
 
 	/* Protect against structure changes of the vgid_to_metadata hash. */
@@ -152,7 +152,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 static void unlock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 
-	DEBUG(s, "unlocking VG %s", id);
+	DEBUGLOG(s, "unlocking VG %s", id);
 	/* Protect the s->lock.vg structure from concurrent access. */
 	pthread_mutex_lock(&s->lock.vg_lock_map);
 	if ((vg = dm_hash_lookup(s->lock.vg, id)))
@@ -437,7 +437,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	buffer_init( &res.buffer );
 
-	DEBUG(s, "vg_lookup: uuid = %s, name = %s", uuid, name);
+	DEBUGLOG(s, "vg_lookup: uuid = %s, name = %s", uuid, name);
 
 	if (!uuid || !name) {
 		lock_vgid_to_metadata(s);
@@ -448,7 +448,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 		unlock_vgid_to_metadata(s);
 	}
 
-	DEBUG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
+	DEBUGLOG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
 
 	if (!uuid)
 		return reply_unknown("VG not found");
@@ -533,7 +533,7 @@ static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
 		result = compare_config(a->child, b->child);
 
 	if (result) {
-		// DEBUG("config inequality at %s / %s", a->key, b->key);
+		// DEBUGLOG("config inequality at %s / %s", a->key, b->key);
 		return result;
 	}
 
@@ -579,7 +579,7 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
 			goto out;
 
-		DEBUG(s, "moving PV %s to VG %s", pvid, vgid);
+		DEBUGLOG(s, "moving PV %s to VG %s", pvid, vgid);
 	}
 
 	for (n = dm_hash_get_first(to_check); n;
@@ -649,7 +649,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
 	}
 
 	if (missing) {
-		DEBUG(s, "removing empty VG %s", vgid);
+		DEBUGLOG(s, "removing empty VG %s", vgid);
 		remove_metadata(s, vgid, 0);
 	}
 
@@ -702,17 +702,17 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 		retval = 1;
 		if (compare_config(metadata, old->root))
 			retval = 0;
-		DEBUG(s, "Not updating metadata for %s at %d (%s)", _vgid, haveseq,
+		DEBUGLOG(s, "Not updating metadata for %s at %d (%s)", _vgid, haveseq,
 		      retval ? "ok" : "MISMATCH");
 		if (!retval) {
-			DEBUG_cft(s, "OLD: ", old->root);
-			DEBUG_cft(s, "NEW: ", metadata);
+			DEBUGLOG_cft(s, "OLD: ", old->root);
+			DEBUGLOG_cft(s, "NEW: ", metadata);
 		}
 		goto out;
 	}
 
 	if (seq < haveseq) {
-		DEBUG(s, "Refusing to update metadata for %s (at %d) to %d", _vgid, haveseq, seq);
+		DEBUGLOG(s, "Refusing to update metadata for %s (at %d) to %d", _vgid, haveseq, seq);
 		/* TODO: notify the client that their metadata is out of date? */
 		retval = 1;
 		goto out;
@@ -727,7 +727,7 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid || !name) {
-		DEBUG(s, "Name '%s' or uuid '%s' missing!", name, vgid);
+		DEBUGLOG(s, "Name '%s' or uuid '%s' missing!", name, vgid);
 		goto out;
 	}
 
@@ -740,7 +740,7 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 	}
 
 	lock_vgid_to_metadata(s);
-	DEBUG(s, "Mapping %s to %s", vgid, name);
+	DEBUGLOG(s, "Mapping %s to %s", vgid, name);
 
 	retval = ((cfgname = dm_pool_strdup(dm_config_memory(cft), name)) &&
 		  dm_hash_insert(s->vgid_to_metadata, vgid, cft) &&
@@ -767,7 +767,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	struct dm_config_tree *pvmeta;
 	char *pvid_old;
 
-	DEBUG(s, "pv_gone: %s / %" PRIu64, pvid, device);
+	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && device > 0)
@@ -777,7 +777,7 @@ static response pv_gone(lvmetad_state *s, request r)
 		return reply_unknown("device not in cache");
 	}
 
-	DEBUG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
+	DEBUGLOG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
@@ -798,7 +798,7 @@ static response pv_gone(lvmetad_state *s, request r)
 
 static response pv_clear_all(lvmetad_state *s, request r)
 {
-	DEBUG(s, "pv_clear_all");
+	DEBUGLOG(s, "pv_clear_all");
 
 	lock_pvid_to_pvmeta(s);
 	lock_vgid_to_metadata(s);
@@ -844,7 +844,7 @@ static response pv_found(lvmetad_state *s, request r)
 	}
 	pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 
-	DEBUG(s, "pv_found %s, vgid = %s, device = %" PRIu64 ", old = %s", pvid, vgid, device, old);
+	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 ", old = %s", pvid, vgid, device, old);
 
 	dm_free(old);
 
@@ -870,7 +870,7 @@ static response pv_found(lvmetad_state *s, request r)
 	if (metadata) {
 		if (!vgid)
 			return reply_fail("need VG UUID");
-		DEBUG(s, "obtained vgid = %s, vgname = %s", vgid, vgname);
+		DEBUGLOG(s, "obtained vgid = %s, vgname = %s", vgid, vgname);
 		if (!vgname)
 			return reply_fail("need VG name");
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
@@ -934,7 +934,7 @@ static response vg_remove(lvmetad_state *s, request r)
 	if (!vgid)
 		return reply_fail("need VG UUID");
 
-	DEBUG(s, "vg_remove: %s", vgid);
+	DEBUGLOG(s, "vg_remove: %s", vgid);
 
 	lock_pvid_to_vgid(s);
 	remove_metadata(s, vgid, 1);
@@ -1101,7 +1101,7 @@ static int init(daemon_state *s)
 	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->log_config, 1))
 		return 0;
 
-	DEBUG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
+	DEBUGLOG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
 	if (!ls->pvid_to_vgid || !ls->vgid_to_metadata)
 		return 0;
 
@@ -1116,7 +1116,7 @@ static int fini(daemon_state *s)
 	lvmetad_state *ls = s->private;
 	struct dm_hash_node *n;
 
-	DEBUG(s, "fini");
+	DEBUGLOG(s, "fini");
 
 	destroy_metadata_hashes(ls);
 
diff --git a/libdaemon/server/daemon-log.h b/libdaemon/server/daemon-log.h
index f09fc2a..e2e11c5 100644
--- a/libdaemon/server/daemon-log.h
+++ b/libdaemon/server/daemon-log.h
@@ -23,13 +23,8 @@ enum { DAEMON_LOG_FATAL = 0 /* usually preceding daemon death */
      , DAEMON_LOG_DEBUG = 5 /* unsorted debug stuff */
 };
 
-/*
- * FIXME: We are currently compiling with -DDEBUG
- * so this define DEBUG collision needs fixing
- */
-#undef DEBUG
-#define DEBUG(s, x...) daemon_logf((s)->log, DAEMON_LOG_DEBUG, x)
-#define DEBUG_cft(s, i, n) daemon_log_cft((s)->log, DAEMON_LOG_DEBUG, i, n)
+#define DEBUGLOG(s, x...) daemon_logf((s)->log, DAEMON_LOG_DEBUG, x)
+#define DEBUGLOG_cft(s, i, n) daemon_log_cft((s)->log, DAEMON_LOG_DEBUG, i, n)
 #define WARN(s, x...) daemon_logf((s)->log, DAEMON_LOG_WARN, x)
 #define INFO(s, x...) daemon_logf((s)->log, DAEMON_LOG_INFO, x)
 #define ERROR(s, x...) daemon_logf((s)->log, DAEMON_LOG_ERROR, x)


