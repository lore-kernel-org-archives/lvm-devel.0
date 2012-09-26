From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:59 +0000 (UTC)
Subject: master - lvmetad: Clear metadata/PV cache before a token-triggered rescan.
Message-ID: <20120926175559.190A2A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d66634282459438210f1f9ba7e2e4c910e13ba
Commit:        d2d66634282459438210f1f9ba7e2e4c910e13ba
Parent:        e7d3553906f15b9117d0152844f69de33564ab46
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 19 23:18:28 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvmetad: Clear metadata/PV cache before a token-triggered rescan.

---
 daemons/lvmetad/lvmetad-core.c |   82 ++++++++++++++++++++++++++++-----------
 lib/cache/lvmetad.c            |    6 +++
 2 files changed, 65 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 09ba20d..c6cc3d9 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -45,6 +45,38 @@ typedef struct {
 	pthread_mutex_t token_lock;
 } lvmetad_state;
 
+static void destroy_metadata_hashes(lvmetad_state *s)
+{
+	struct dm_hash_node *n = NULL;
+
+	while (n) {
+		dm_config_destroy(dm_hash_get_data(s->vgid_to_metadata, n));
+		n = dm_hash_get_next(s->vgid_to_metadata, n);
+	}
+
+	n = dm_hash_get_first(s->pvid_to_pvmeta);
+	while (n) {
+		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
+		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
+	}
+	dm_hash_destroy(s->pvid_to_pvmeta);
+	dm_hash_destroy(s->vgid_to_metadata);
+	dm_hash_destroy(s->vgid_to_vgname);
+	dm_hash_destroy(s->vgname_to_vgid);
+	dm_hash_destroy(s->device_to_pvid);
+	dm_hash_destroy(s->pvid_to_vgid);
+}
+
+static void create_metadata_hashes(lvmetad_state *s)
+{
+	s->pvid_to_pvmeta = dm_hash_create(32);
+	s->device_to_pvid = dm_hash_create(32);
+	s->vgid_to_metadata = dm_hash_create(32);
+	s->vgid_to_vgname = dm_hash_create(32);
+	s->pvid_to_vgid = dm_hash_create(32);
+	s->vgname_to_vgid = dm_hash_create(32);
+}
+
 static void lock_pvid_to_pvmeta(lvmetad_state *s) {
 	pthread_mutex_lock(&s->lock.pvid_to_pvmeta); }
 static void unlock_pvid_to_pvmeta(lvmetad_state *s) {
@@ -724,6 +756,24 @@ static response pv_gone(lvmetad_state *s, request r)
 		return reply_unknown("PVID does not exist");
 }
 
+static response pv_clear_all(lvmetad_state *s, request r)
+{
+	DEBUG(s, "pv_clear_all");
+
+	lock_pvid_to_pvmeta(s);
+	lock_vgid_to_metadata(s);
+	lock_pvid_to_vgid(s);
+
+	destroy_metadata_hashes(s);
+	create_metadata_hashes(s);
+
+	unlock_pvid_to_vgid(s);
+	unlock_vgid_to_metadata(s);
+	unlock_pvid_to_pvmeta(s);
+
+	return daemon_reply_simple("OK", NULL);
+}
+
 static response pv_found(lvmetad_state *s, request r)
 {
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
@@ -877,6 +927,9 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "pv_gone"))
 		return pv_gone(state, r);
 
+	if (!strcmp(rq, "pv_clear_all"))
+		return pv_clear_all(state, r);
+
 	if (!strcmp(rq, "pv_lookup"))
 		return pv_lookup(state, r);
 
@@ -905,20 +958,16 @@ static int init(daemon_state *s)
 	lvmetad_state *ls = s->private;
 	ls->log = s->log;
 
-	ls->pvid_to_pvmeta = dm_hash_create(32);
-	ls->device_to_pvid = dm_hash_create(32);
-	ls->vgid_to_metadata = dm_hash_create(32);
-	ls->vgid_to_vgname = dm_hash_create(32);
-	ls->pvid_to_vgid = dm_hash_create(32);
-	ls->vgname_to_vgid = dm_hash_create(32);
-	ls->lock.vg = dm_hash_create(32);
-	ls->token[0] = 0;
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
 	pthread_mutex_init(&ls->lock.pvid_to_pvmeta, &rec);
 	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
 	pthread_mutex_init(&ls->token_lock, NULL);
+	create_metadata_hashes(ls);
+
+	ls->lock.vg = dm_hash_create(32);
+	ls->token[0] = 0;
 
 	/* Set up stderr logging depending on the -d option. */
 	daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1);
@@ -939,17 +988,10 @@ static int fini(daemon_state *s)
 	struct dm_hash_node *n = dm_hash_get_first(ls->vgid_to_metadata);
 
 	DEBUG(s, "fini");
-	while (n) {
-		dm_config_destroy(dm_hash_get_data(ls->vgid_to_metadata, n));
-		n = dm_hash_get_next(ls->vgid_to_metadata, n);
-	}
 
-	n = dm_hash_get_first(ls->pvid_to_pvmeta);
-	while (n) {
-		dm_config_destroy(dm_hash_get_data(ls->pvid_to_pvmeta, n));
-		n = dm_hash_get_next(ls->pvid_to_pvmeta, n);
-	}
+	destroy_metadata_hashes(ls);
 
+	/* Destroy the lock hashes now. */
 	n = dm_hash_get_first(ls->lock.vg);
 	while (n) {
 		pthread_mutex_destroy(dm_hash_get_data(ls->lock.vg, n));
@@ -958,12 +1000,6 @@ static int fini(daemon_state *s)
 	}
 
 	dm_hash_destroy(ls->lock.vg);
-	dm_hash_destroy(ls->pvid_to_pvmeta);
-	dm_hash_destroy(ls->device_to_pvid);
-	dm_hash_destroy(ls->vgid_to_metadata);
-	dm_hash_destroy(ls->vgid_to_vgname);
-	dm_hash_destroy(ls->vgname_to_vgid);
-	dm_hash_destroy(ls->pvid_to_vgid);
 	return 1;
 }
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 237fec6..a7e3cd3 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -851,6 +851,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 {
 	struct dev_iter *iter;
 	struct device *dev;
+	daemon_reply reply;
 	int r = 1;
 
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
@@ -858,6 +859,11 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 		return 0;
 	}
 
+	reply = _lvmetad_send("pv_clear_all", NULL);
+	if (!_lvmetad_handle_reply(reply, "clear status on all PVs", "", NULL))
+		r = 0;
+	daemon_reply_destroy(reply);
+
 	while ((dev = dev_iter_get(iter))) {
 		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
 			r = 0;


