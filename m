From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 May 2016 19:40:21 +0000 (UTC)
Subject: master - lvmetad: add request level thread locking
Message-ID: <20160516194021.E7F1E602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f72a52302587fef27d845e218e6a81be6022dca
Commit:        9f72a52302587fef27d845e218e6a81be6022dca
Parent:        7ef152c07290c79f47a64b0fc81975ae52554919
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 10 14:42:26 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 16 14:38:04 2016 -0500

lvmetad: add request level thread locking

Use an rwlock for requests that read/write cache state.
Use a mutex for requests that read/write global info.
---
 daemons/lvmetad/lvmetad-core.c |  103 +++++++++++++++++++++++++++++-----------
 1 files changed, 75 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 54ecd4a..5ff148b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -232,6 +232,8 @@ typedef struct {
 	char token[128];
 	uint32_t flags; /* GLFL_ */
 	pthread_mutex_t token_lock;
+	pthread_mutex_t info_lock;
+	pthread_rwlock_t cache_lock;
 } lvmetad_state;
 
 static void destroy_metadata_hashes(lvmetad_state *s)
@@ -2783,10 +2785,13 @@ static response dump(lvmetad_state *s)
 
 static response handler(daemon_state s, client_handle h, request r)
 {
+	response res = { 0 };
 	lvmetad_state *state = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
 	const char *token = daemon_request_str(r, "token", "NONE");
 	char prev_token[128] = { 0 };
+	int cache_lock = 0;
+	int info_lock = 0;
 
 	pthread_mutex_lock(&state->token_lock);
 	if (!strcmp(rq, "token_update")) {
@@ -2813,49 +2818,89 @@ static response handler(daemon_state s, client_handle h, request r)
 	 * TODO Add a stats call, with transaction count/rate, time since last
 	 * update &c.
 	 */
+
+	if (!strcmp(rq, "pv_found") ||
+	    !strcmp(rq, "pv_gone") ||
+	    !strcmp(rq, "vg_update") ||
+	    !strcmp(rq, "vg_remove") ||
+	    !strcmp(rq, "set_vg_info") ||
+	    !strcmp(rq, "pv_clear_all") ||
+	    !strcmp(rq, "vg_clear_outdated_pvs")) {
+		pthread_rwlock_wrlock(&state->cache_lock);
+		cache_lock = 1;
+		goto do_rq;
+	}
+
+	if (!strcmp(rq, "pv_lookup") ||
+	    !strcmp(rq, "vg_lookup") ||
+	    !strcmp(rq, "pv_list") ||
+	    !strcmp(rq, "vg_list") ||
+	    !strcmp(rq, "dump")) {
+		pthread_rwlock_rdlock(&state->cache_lock);
+		cache_lock = 1;
+		goto do_rq;
+	}
+
+	if (!strcmp(rq, "set_global_info") ||
+	    !strcmp(rq, "get_global_info")) {
+		pthread_mutex_lock(&state->info_lock);
+		info_lock = 1;
+		goto do_rq;
+	}
+
+ do_rq:
+
 	if (!strcmp(rq, "pv_found"))
-		return pv_found(state, r);
+		res = pv_found(state, r);
 
-	if (!strcmp(rq, "pv_gone"))
-		return pv_gone(state, r);
+	else if (!strcmp(rq, "pv_gone"))
+		res = pv_gone(state, r);
 
-	if (!strcmp(rq, "pv_clear_all"))
-		return pv_clear_all(state, r);
+	else if (!strcmp(rq, "pv_clear_all"))
+		res = pv_clear_all(state, r);
 
-	if (!strcmp(rq, "pv_lookup"))
-		return pv_lookup(state, r);
+	else if (!strcmp(rq, "pv_lookup"))
+		res = pv_lookup(state, r);
 
-	if (!strcmp(rq, "vg_update"))
-		return vg_update(state, r);
+	else if (!strcmp(rq, "vg_update"))
+		res = vg_update(state, r);
 
-	if (!strcmp(rq, "vg_clear_outdated_pvs"))
-		return vg_clear_outdated_pvs(state, r);
+	else if (!strcmp(rq, "vg_clear_outdated_pvs"))
+		res = vg_clear_outdated_pvs(state, r);
 
-	if (!strcmp(rq, "vg_remove"))
-		return vg_remove(state, r);
+	else if (!strcmp(rq, "vg_remove"))
+		res = vg_remove(state, r);
 
-	if (!strcmp(rq, "vg_lookup"))
-		return vg_lookup(state, r);
+	else if (!strcmp(rq, "vg_lookup"))
+		res = vg_lookup(state, r);
 
-	if (!strcmp(rq, "pv_list"))
-		return pv_list(state, r);
+	else if (!strcmp(rq, "pv_list"))
+		res = pv_list(state, r);
 
-	if (!strcmp(rq, "vg_list"))
-		return vg_list(state, r);
+	else if (!strcmp(rq, "vg_list"))
+		res = vg_list(state, r);
 
-	if (!strcmp(rq, "set_global_info"))
-		return set_global_info(state, r);
+	else if (!strcmp(rq, "set_global_info"))
+		res = set_global_info(state, r);
 
-	if (!strcmp(rq, "get_global_info"))
-		return get_global_info(state, r);
+	else if (!strcmp(rq, "get_global_info"))
+		res = get_global_info(state, r);
 
-	if (!strcmp(rq, "set_vg_info"))
-		return set_vg_info(state, r);
+	else if (!strcmp(rq, "set_vg_info"))
+		res = set_vg_info(state, r);
 
-	if (!strcmp(rq, "dump"))
-		return dump(state);
+	else if (!strcmp(rq, "dump"))
+		res = dump(state);
 
-	return reply_fail("request not implemented");
+	else
+		res = reply_fail("request not implemented");
+
+	if (cache_lock)
+		pthread_rwlock_unlock(&state->cache_lock);
+	if (info_lock)
+		pthread_mutex_unlock(&state->info_lock);
+
+	return res;
 }
 
 static int init(daemon_state *s)
@@ -2871,6 +2916,8 @@ static int init(daemon_state *s)
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
 	pthread_mutex_init(&ls->lock.vg_lock_map, NULL);
 	pthread_mutex_init(&ls->token_lock, NULL);
+	pthread_mutex_init(&ls->info_lock, NULL);
+	pthread_rwlock_init(&ls->cache_lock, NULL);
 	create_metadata_hashes(ls);
 
 	ls->lock.vg = dm_hash_create(32);


