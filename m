From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:45 +0000 (UTC)
Subject: master - Implement devices/global_filter.
Message-ID: <20120926175545.51DEEA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b17836ea139ba7448f5a5c1d2fbe93676baa36
Commit:        c7b17836ea139ba7448f5a5c1d2fbe93676baa36
Parent:        ceb79c9a500f38ac31c8d79904c3730805feb3dc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 13 19:44:10 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 14:49:15 2012 +0200

Implement devices/global_filter.

The global filter is applied first, and is also applied in pvscan --cache (which
is called from udev rules to keep lvmetad updated). Cf. example.conf.
---
 daemons/lvmetad/lvmetad-core.c   |   87 +++++++++++++-------
 doc/example.conf.in              |    8 ++
 lib/cache/lvmcache.c             |    2 -
 lib/cache/lvmetad.c              |  167 ++++++++++++++++++++++++++++++--------
 lib/cache/lvmetad.h              |   27 ++++++-
 lib/commands/toolcontext.c       |   45 +++++++++--
 lib/commands/toolcontext.h       |    1 +
 lib/device/dev-cache.c           |    4 +-
 lib/device/dev-cache.h           |    1 +
 lib/filters/filter-persistent.c  |    5 +-
 lib/filters/filter-persistent.h  |    1 -
 libdaemon/client/daemon-shared.c |    4 +-
 test/lib/aux.sh                  |    2 +-
 tools/pvscan.c                   |   31 +-------
 tools/vgrename.c                 |    3 +-
 tools/vgscan.c                   |    3 +-
 16 files changed, 279 insertions(+), 112 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index c96e285..09ba20d 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -41,6 +41,8 @@ typedef struct {
 		pthread_mutex_t vgid_to_metadata;
 		pthread_mutex_t pvid_to_vgid;
 	} lock;
+	char token[128];
+	pthread_mutex_t token_lock;
 } lvmetad_state;
 
 static void lock_pvid_to_pvmeta(lvmetad_state *s) {
@@ -58,6 +60,16 @@ static void lock_pvid_to_vgid(lvmetad_state *s) {
 static void unlock_pvid_to_vgid(lvmetad_state *s) {
 	pthread_mutex_unlock(&s->lock.pvid_to_vgid); }
 
+static response reply_fail(const char *reason)
+{
+	return daemon_reply_simple("failed", "reason = %s", reason, NULL);
+}
+
+static response reply_unknown(const char *reason)
+{
+	return daemon_reply_simple("unknown", "reason = %s", reason, NULL);
+}
+
 /*
  * TODO: It may be beneficial to clean up the vg lock hash from time to time,
  * since if we have many "rogue" requests for nonexistent things, we will keep
@@ -257,13 +269,13 @@ static response pv_lookup(lvmetad_state *s, request r)
 	struct dm_config_node *pv;
 
 	if (!pvid && !devt)
-		return daemon_reply_simple("failed", "reason = %s", "need PVID or device", NULL);
+		return reply_fail("need PVID or device");
 
 	if (!(res.cft = dm_config_create()))
-		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+		return reply_fail("out of memory");
 
 	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
-		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+		return reply_fail("out of memory");
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && devt)
@@ -273,14 +285,14 @@ static response pv_lookup(lvmetad_state *s, request r)
 		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
-		return daemon_reply_simple("unknown", "reason = %s", "device not found", NULL);
+		return reply_unknown("device not found");
 	}
 
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
-		return daemon_reply_simple("unknown", "reason = %s", "PV not found", NULL);
+		return reply_unknown("PV not found");
 	}
 
 	pv->key = "physical_volume";
@@ -381,12 +393,12 @@ static response vg_lookup(lvmetad_state *s, request r)
 	DEBUG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
 
 	if (!uuid)
-		return daemon_reply_simple("unknown", "reason = %s", "VG not found", NULL);
+		return reply_unknown("VG not found");
 
 	cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
-		return daemon_reply_simple("unknown", "reason = %s", "UUID not found", NULL);
+		return reply_unknown("UUID not found");
 	}
 
 	metadata = cft->root;
@@ -426,7 +438,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	return res;
 bad:
 	unlock_vg(s, uuid);
-	return daemon_reply_simple("failed", "reason = %s", "Out of memory", NULL);
+	return reply_fail("out of memory");
 }
 
 static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
@@ -694,7 +706,7 @@ static response pv_gone(lvmetad_state *s, request r)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	if (!pvid) {
 		unlock_pvid_to_pvmeta(s);
-		return daemon_reply_simple("unknown", "reason = %s", "device not in cache", NULL);
+		return reply_unknown("device not in cache");
 	}
 
 	DEBUG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
@@ -709,7 +721,7 @@ static response pv_gone(lvmetad_state *s, request r)
 		dm_config_destroy(pvmeta);
 		return daemon_reply_simple("OK", NULL);
 	} else
-		return daemon_reply_simple("unknown", "reason = %s", "PVID does not exist", NULL);
+		return reply_unknown("PVID does not exist");
 }
 
 static response pv_found(lvmetad_state *s, request r)
@@ -726,12 +738,12 @@ static response pv_found(lvmetad_state *s, request r)
 	int complete = 0, orphan = 0;
 
 	if (!pvid)
-		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
+		return reply_fail("need PV UUID");
 	if (!pvmeta)
-		return daemon_reply_simple("failed", "reason = %s", "need PV metadata", NULL);
+		return reply_fail("need PV metadata");
 
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
-		return daemon_reply_simple("failed", "reason = %s", "need PV device number", NULL);
+		return reply_fail("need PV device number");
 
 	DEBUG(s, "pv_found %s, vgid = %s, device = %" PRIu64, pvid, vgid, device);
 
@@ -745,14 +757,14 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!(cft = dm_config_create()) ||
 	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
 		unlock_pvid_to_pvmeta(s);
-		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+		return reply_fail("out of memory");
 	}
 
 	pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
 		unlock_pvid_to_pvmeta(s);
-		return daemon_reply_simple("failed", "reason = %s", "out of memory", NULL);
+		return reply_fail("out of memory");
 	}
 	if (pvmeta_old)
 		dm_config_destroy(pvmeta_old);
@@ -761,16 +773,15 @@ static response pv_found(lvmetad_state *s, request r)
 
 	if (metadata) {
 		if (!vgid)
-			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+			return reply_fail("need VG UUID");
 		DEBUG(s, "obtained vgid = %s, vgname = %s", vgid, vgname);
 		if (!vgname)
-			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
+			return reply_fail("need VG name");
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
-			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
+			return reply_fail("need VG seqno");
 
 		if (!update_metadata(s, vgname, vgid, metadata))
-			return daemon_reply_simple("failed", "reason = %s",
-						   "metadata update failed", NULL);
+			return reply_fail("metadata update failed");
 	} else {
 		lock_pvid_to_vgid(s);
 		vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
@@ -784,8 +795,7 @@ static response pv_found(lvmetad_state *s, request r)
 			orphan = 1;
 		else {
 			unlock_vg(s, vgid);
-			return daemon_reply_simple("failed", "reason = %s",
-						   "non-orphan VG without metadata encountered", NULL);
+			return reply_fail("non-orphan VG without metadata encountered");
 		}
 		unlock_vg(s, vgid);
 	}
@@ -804,17 +814,16 @@ static response vg_update(lvmetad_state *s, request r)
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
 	if (metadata) {
 		if (!vgid)
-			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+			return reply_fail("need VG UUID");
 		if (!vgname)
-			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
+			return reply_fail("need VG name");
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
-			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
+			return reply_fail("need VG seqno");
 
 		/* TODO defer metadata update here; add a separate vg_commit
 		 * call; if client does not commit, die */
 		if (!update_metadata(s, vgname, vgid, metadata))
-			return daemon_reply_simple("failed", "reason = %s",
-						   "metadata update failed", NULL);
+			return reply_fail("metadata update failed");
 	}
 	return daemon_reply_simple("OK", NULL);
 }
@@ -824,7 +833,7 @@ static response vg_remove(lvmetad_state *s, request r)
 	const char *vgid = daemon_request_str(r, "uuid", NULL);
 
 	if (!vgid)
-		return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		return reply_fail("need VG UUID");
 
 	DEBUG(s, "vg_remove: %s", vgid);
 
@@ -839,6 +848,24 @@ static response handler(daemon_state s, client_handle h, request r)
 {
 	lvmetad_state *state = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
+	const char *token = daemon_request_str(r, "token", "NONE");
+
+	pthread_mutex_lock(&state->token_lock);
+	if (!strcmp(rq, "token_update")) {
+		strncpy(state->token, token, 128);
+		state->token[127] = 0;
+		pthread_mutex_unlock(&state->token_lock);
+		return daemon_reply_simple("OK", NULL);
+	}
+
+	if (strcmp(token, state->token)) {
+		pthread_mutex_unlock(&state->token_lock);
+		return daemon_reply_simple("token_mismatch",
+					   "expected = %s", state->token,
+					   "received = %s", token,
+					   "reason = %s", "token mismatch", NULL);
+	}
+	pthread_mutex_unlock(&state->token_lock);
 
 	/*
 	 * TODO Add a stats call, with transaction count/rate, time since last
@@ -869,7 +896,7 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "vg_list"))
 		return vg_list(state, r);
 
-	return daemon_reply_simple("failed", "reason = %s", "no such request", NULL);
+	return reply_fail("request not implemented");
 }
 
 static int init(daemon_state *s)
@@ -885,11 +912,13 @@ static int init(daemon_state *s)
 	ls->pvid_to_vgid = dm_hash_create(32);
 	ls->vgname_to_vgid = dm_hash_create(32);
 	ls->lock.vg = dm_hash_create(32);
+	ls->token[0] = 0;
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
 	pthread_mutex_init(&ls->lock.pvid_to_pvmeta, &rec);
 	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
+	pthread_mutex_init(&ls->token_lock, NULL);
 
 	/* Set up stderr logging depending on the -d option. */
 	daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1);
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 7b26bdc..b4cda6f 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -79,6 +79,14 @@ devices {
     # Use anchors if you want to be really specific
     # filter = [ "a|^/dev/hda8$|", "r/.*/" ]
 
+    # Since "filter" is often overriden from command line, it is not suitable
+    # for system-wide device filtering (udev rules, lvmetad). To hide devices
+    # from LVM-specific udev processing and/or from lvmetad, you need to set
+    # global_filter. The syntax is the same as for normal "filter"
+    # above. Devices that fail the global_filter are not even opened by LVM.
+
+    # global_filter = []
+
     # The results of the filtering are cached on disk to avoid
     # rescanning dud devices (which can take a very long time).
     # By default this cache is stored in the @DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@ directory
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6f9cfad..2c431b1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -109,8 +109,6 @@ int lvmcache_init(void)
 		_vg_global_lock_held = 0;
 	}
 
-	lvmetad_init();
-
 	return 1;
 }
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 53dbab0..90d43dd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,38 +20,120 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
+#include "filter.h"
+#include "assert.h"
+#include "crc.h"
 
-static int _using_lvmetad = 0;
 static daemon_handle _lvmetad;
-static const char *_lvmetad_token;
+static int _lvmetad_use = 0;
+static int _lvmetad_connected = 0;
 
-void lvmetad_init(void)
+static char *_lvmetad_token = NULL;
+static const char *_lvmetad_socket = NULL;
+static struct cmd_context *_lvmetad_cmd = NULL;
+
+void lvmetad_disconnect(void)
+{
+	daemon_close(_lvmetad);
+	_lvmetad_connected = 0;
+	_lvmetad_cmd = NULL;
+}
+
+void lvmetad_init(struct cmd_context *cmd)
 {
-	const char *socket = getenv("LVM_LVMETAD_SOCKET");
-	if (_using_lvmetad) { /* configured by the toolcontext */
-		_lvmetad = lvmetad_open(socket ?: DEFAULT_RUN_DIR "/lvmetad.socket");
-		if (_lvmetad.socket_fd < 0 || _lvmetad.error) {
+	if (_lvmetad_use && _lvmetad_socket && !_lvmetad_connected) {
+		assert(_lvmetad_socket);
+		_lvmetad = lvmetad_open(_lvmetad_socket);
+		if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
+			_lvmetad_connected = 1;
+			_lvmetad_cmd = cmd;
+		} else
 			log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.", strerror(_lvmetad.error));
-			_using_lvmetad = 0;
-		}
 	}
 }
 
+int lvmetad_active(void)
+{
+	return _lvmetad_use && _lvmetad_connected;
+}
+
+void lvmetad_set_active(int active)
+{
+	_lvmetad_use = active;
+}
+
+void lvmetad_set_token(const struct dm_config_value *filter)
+{
+	if (_lvmetad_token)
+		dm_free(_lvmetad_token);
+	int ft = 0;
+	while (filter && filter->type == DM_CFG_STRING) {
+		ft = calc_crc(ft, (const uint8_t *) filter->v.str, strlen(filter->v.str));
+		filter = filter->next;
+	}
+	if (!dm_asprintf(&_lvmetad_token, "filter:%u", ft))
+		log_warn("WARNING: Failed to set lvmetad token. Out of memory?");
+}
+
+void lvmetad_set_socket(const char *sock)
+{
+	_lvmetad_socket = sock;
+}
+
+static daemon_reply _lvmetad_send(const char *id, ...);
+
+static int _token_update()
+{
+	daemon_reply repl = _lvmetad_send("token_update", NULL);
+
+	if (strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
+		daemon_reply_destroy(repl);
+		return 0;
+	}
+
+	daemon_reply_destroy(repl);
+	return 1;
+}
+
+
 static daemon_reply _lvmetad_send(const char *id, ...)
 {
 	va_list ap;
-	va_start(ap, id);
-	daemon_reply repl;
-	daemon_request req = daemon_request_make(id);
+	daemon_reply repl, token_set;
+	daemon_request req;
+	int try = 0;
+	char *future_token;
 
-	// daemon_request_extend(req, "token", _lvmetad_token, NULL);
+retry:
+	req = daemon_request_make(id);
+
+	if (_lvmetad_token)
+		daemon_request_extend(req, "token = %s", _lvmetad_token, NULL);
+
+	va_start(ap, id);
 	daemon_request_extend_v(req, ap);
+	va_end(ap);
 
 	repl = daemon_send(_lvmetad, req);
 
 	daemon_request_destroy(req);
 
-	va_end(ap);
+	if (!strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") && try < 2 && !test_mode()) {
+		future_token = _lvmetad_token;
+		_lvmetad_token = (char *) "update in progress";
+		if (!_token_update()) goto out;
+
+		if (pvscan_lvmetad_all_devs(_lvmetad_cmd, NULL)) {
+			_lvmetad_token = future_token;
+			if (!_token_update()) goto out;
+		}
+		_lvmetad_token = future_token;
+		++ try;
+		daemon_reply_destroy(repl);
+		goto retry;
+	}
+
+out:
 	return repl;
 }
 
@@ -203,7 +285,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
 
-	if (!_using_lvmetad)
+	if (!lvmetad_active())
 		return NULL;
 
 	if (vgid) {
@@ -317,7 +399,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!vg)
 		return 0;
 
-	if (!_using_lvmetad || test_mode())
+	if (!lvmetad_active() || test_mode())
 		return 1; /* fake it */
 
 	if (!(vgmeta = _export_vg_to_config_tree(vg)))
@@ -369,7 +451,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	daemon_reply reply;
 	int result;
 
-	if (!_using_lvmetad || test_mode())
+	if (!lvmetad_active() || test_mode())
 		return 1; /* just fake it */
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
@@ -390,7 +472,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 	int result = 0;
 	struct dm_config_node *cn;
 
-	if (!_using_lvmetad)
+	if (!lvmetad_active())
 		return_0;
 
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
@@ -423,7 +505,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!_using_lvmetad)
+	if (!lvmetad_active())
 		return_0;
 
 	reply = _lvmetad_send("pv_lookup", "device = %d", dev->dev, NULL);
@@ -450,7 +532,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!_using_lvmetad)
+	if (!lvmetad_active())
 		return 1;
 
 	reply = _lvmetad_send("pv_list", NULL);
@@ -476,7 +558,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!_using_lvmetad)
+	if (!lvmetad_active())
 		return 1;
 
 	reply = _lvmetad_send("vg_list", NULL);
@@ -576,7 +658,7 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	const char *status;
 	int result;
 
-	if (!_using_lvmetad || test_mode())
+	if (!lvmetad_active() || test_mode())
 		return 1;
 
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
@@ -659,7 +741,7 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handle
 	int result;
 	int found;
 
-	if (!_using_lvmetad || test_mode())
+	if (!lvmetad_active() || test_mode())
 		return 1;
 
 	/*
@@ -669,7 +751,7 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handle
          *        the whole stack from top to bottom (not yet upstream).
          */
 
-	reply = daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
+	reply = _lvmetad_send("pv_gone", "device = %d", device, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
 	/* We don't care whether or not the daemon had the PV cached. */
@@ -684,16 +766,6 @@ int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler)
 	return lvmetad_pv_gone(dev->dev, dev_name(dev), handler);
 }
 
-int lvmetad_active(void)
-{
-	return _using_lvmetad;
-}
-
-void lvmetad_set_active(int active)
-{
-	_using_lvmetad = active;
-}
-
 /*
  * The following code implements pvscan --cache.
  */
@@ -771,3 +843,30 @@ bad:
 		  "It is strongly recommended that you restart lvmetad immediately.");
 	return 0;
 }
+
+int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	int r = 1;
+
+	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
+		log_error("dev_iter creation failed");
+		return 0;
+	}
+
+	while ((dev = dev_iter_get(iter))) {
+		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
+			r = 0;
+			break;
+		}
+
+		if (sigint_caught())
+			break;
+	}
+
+	dev_iter_destroy(iter);
+
+	return r;
+}
+
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 7a6fe0b..cb85929 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -30,7 +30,7 @@ typedef int (*activation_handler) (struct volume_group *vg, int partial,
  * Initialise the communication with lvmetad. Normally called by
  * lvmcache_init. Sets up a global handle for our process.
  */
-void lvmetad_init(void);
+void lvmetad_init(struct cmd_context *);
 
 /*
  * Override the use of lvmetad for retrieving scan results and metadata.
@@ -38,12 +38,29 @@ void lvmetad_init(void);
 void lvmetad_set_active(int);
 
 /*
+ * Configure the socket that lvmetad_init will use to connect to the daemon.
+ */
+void lvmetad_set_socket(const char *);
+
+/*
  * Check whether lvmetad is active (where active means both that it is running
  * and that we have a working connection with it).
  */
 int lvmetad_active(void);
 
 /*
+ * Drop connection to lvmetad. A subsequent lvmetad_init() will re-establish
+ * the connection (possibly at a different socket path).
+ */
+void lvmetad_disconnect(void);
+
+/*
+ * Set the "lvmetad validity token" (currently only consists of the lvmetad
+ * filter. See lvm.conf.
+ */
+void lvmetad_set_token(const struct dm_config_value *filter);
+
+/*
  * Send a new version of VG metadata to lvmetad. This is normally called after
  * vg_write but before vg_commit. After vg_commit, lvmetad_vg_commit is called
  * to seal the transaction. The result of lvmetad_vg_update is that the new
@@ -111,11 +128,16 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
 int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler);
 
+int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler);
+
 #  else		/* LVMETAD_SUPPORT */
 
-#    define lvmetad_init()	do { } while (0)
+#    define lvmetad_init(cmd)	do { } while (0)
+#    define lvmetad_disconnect()	do { } while (0)
 #    define lvmetad_set_active(a)	do { } while (0)
+#    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_active()	(0)
+#    define lvmetad_set_token(a)	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
 #    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg, handler)	(1)
@@ -127,6 +149,7 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
 #    define pvscan_lvmetad_single(cmd, dev, handler)	(0)
+#    define pvscan_lvmetad_all_devs(cmd, handler)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 9c2404f..c5e0ee3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -399,7 +399,20 @@ static int _process_config(struct cmd_context *cmd)
 		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption",
 				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
 
+	lvmetad_disconnect();
+	const char *lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
+	if (!lvmetad_socket)
+		lvmetad_socket = DEFAULT_RUN_DIR "/lvmetad.socket";
+
+	/* TODO?
+		lvmetad_socket = find_config_tree_str(cmd, "lvmetad/socket_path",
+						      DEFAULT_RUN_DIR "/lvmetad.socket");
+	*/
+	lvmetad_set_socket(lvmetad_socket);
+	cn = find_config_tree_node(cmd, "devices/global_filter");
+	lvmetad_set_token(cn ? cn->v : NULL);
 	lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+	lvmetad_init(cmd);
 
 	return 1;
 }
@@ -818,13 +831,14 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 {
 	static char cache_file[PATH_MAX];
 	const char *dev_cache = NULL, *cache_dir, *cache_file_prefix;
-	struct dev_filter *f3, *f4;
+	struct dev_filter *f3 = NULL, *f4 = NULL, *toplevel_components[2] = { 0 };
 	struct stat st;
+	const struct dm_config_node *cn;
 
 	cmd->dump_filter = 0;
 
 	if (!(f3 = _init_filter_components(cmd)))
-		return_0;
+		goto_bad;
 
 	init_ignore_suspended_devices(find_config_tree_int(cmd,
 	    "devices/ignore_suspended_devices", DEFAULT_IGNORE_SUSPENDED_DEVICES));
@@ -843,8 +857,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
 		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
 			log_error("Persistent cache filename too long.");
-			f3->destroy(f3);
-			return 0;
+			goto bad;
 		}
 	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
 		   (dm_snprintf(cache_file, sizeof(cache_file),
@@ -852,8 +865,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
 				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
 		log_error("Persistent cache filename too long.");
-		f3->destroy(f3);
-		return 0;
+		goto bad;
 	}
 
 	if (!dev_cache)
@@ -883,9 +895,26 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
 
-	cmd->filter = f4;
+	if (!(cn = find_config_tree_node(cmd, "devices/global_filter"))) {
+		cmd->filter = f4;
+	} else if (!(cmd->lvmetad_filter = regex_filter_create(cn->v)))
+		goto_bad;
+	else {
+		toplevel_components[0] = cmd->lvmetad_filter;
+		toplevel_components[1] = f4;
+		if (!(cmd->filter = composite_filter_create(2, toplevel_components)))
+			goto_bad;
+	}
 
 	return 1;
+bad:
+	if (f3)
+		f3->destroy(f3);
+	if (f4)
+		f4->destroy(f4);
+	if (toplevel_components[0])
+		toplevel_components[0]->destroy(toplevel_components[0]);
+	return 0;
 }
 
 struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format)
@@ -1495,6 +1524,8 @@ int refresh_filters(struct cmd_context *cmd)
 		cmd->filter = NULL;
 	}
 
+	cmd->lvmetad_filter = NULL;
+
 	if (!(r = _init_filters(cmd, 0)))
                 stack;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index e0ef041..6e5803f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -91,6 +91,7 @@ struct cmd_context {
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 
 	struct dev_filter *filter;
+	struct dev_filter *lvmetad_filter;
 	int dump_filter;	/* Dump filter when exiting? */
 
 	struct dm_list config_files;
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1da9a77..79b3028 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -971,8 +971,8 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 
 	if (dev_scan && !trust_cache()) {
 		/* Flag gets reset between each command */
-		if (!full_scan_done() && f)
-			persistent_filter_wipe(f); /* Calls _full_scan(1) */
+		if (!full_scan_done() && f && f->wipe)
+			f->wipe(f); /* Calls _full_scan(1) */
 	} else
 		_full_scan(0);
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index f3511cc..3267c9d 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -25,6 +25,7 @@
 struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
+	void (*wipe) (struct dev_filter * f);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 79e40b8..d00a99a 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -51,7 +51,7 @@ static int _init_hash(struct pfilter *pf)
 	return 1;
 }
 
-int persistent_filter_wipe(struct dev_filter *f)
+static void _persistent_filter_wipe(struct dev_filter *f)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 
@@ -60,8 +60,6 @@ int persistent_filter_wipe(struct dev_filter *f)
 
 	/* Trigger complete device scan */
 	dev_cache_scan(1);
-
-	return 1;
 }
 
 static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
@@ -368,6 +366,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	f->destroy = _persistent_destroy;
 	f->use_count = 0;
 	f->private = pf;
+	f->wipe = _persistent_filter_wipe;
 
 	return f;
 
diff --git a/lib/filters/filter-persistent.h b/lib/filters/filter-persistent.h
index ad56a62..c2eee30 100644
--- a/lib/filters/filter-persistent.h
+++ b/lib/filters/filter-persistent.h
@@ -21,7 +21,6 @@
 struct dev_filter *persistent_filter_create(struct dev_filter *f,
 					    const char *file);
 
-int persistent_filter_wipe(struct dev_filter *f);
 int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
 int persistent_filter_dump(struct dev_filter *f, int merge_existing);
 
diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index 40c02b0..4b98f51 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -221,8 +221,10 @@ static void chain_node(struct dm_config_node *cn,
 
 	if (parent && !parent->child)
 		parent->child = cn;
-	if (pre_sib)
+	if (pre_sib) {
+		cn->sib = pre_sib->sib;
 		pre_sib->sib = cn;
+	}
 
 }
 
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0b46c79..d6a2008 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -527,5 +527,5 @@ target_at_least()
 
 test -f DEVICES && devs=$(cat DEVICES)
 
-unset LVM_VALGRIND
+#unset LVM_VALGRIND
 "$@"
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 9287388..239ce97 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -106,32 +106,6 @@ static int _auto_activation_handler(struct volume_group *vg, int partial,
 	return 1;
 }
 
-static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
-{
-	struct dev_iter *iter;
-	struct device *dev;
-	int r = 1;
-
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
-		return 0;
-	}
-
-	while ((dev = dev_iter_get(iter))) {
-		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
-			r = 0;
-			break;
-		}
-
-		if (sigint_caught())
-			break;
-	}
-
-	dev_iter_destroy(iter);
-
-	return r;
-}
-
 static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret = ECMD_PROCESSED;
@@ -168,7 +142,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Scan everything? */
 	if (!argc && !devno_args) {
-		if (!_pvscan_lvmetad_all_devs(cmd, handler))
+		if (!pvscan_lvmetad_all_devs(cmd, handler))
 			ret = ECMD_FAILED;
 		goto out;
 	}
@@ -283,7 +257,8 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	persistent_filter_wipe(cmd->filter);
+	if (cmd->filter->wipe)
+		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
 
 	/* populate lvmcache */
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 451d085..b476602 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -181,7 +181,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 				vg_name_old, vg_name_new);
 
 	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
-	persistent_filter_wipe(cmd->filter);
+	if (cmd->filter->wipe)
+		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
 
 	return 1;
diff --git a/tools/vgscan.c b/tools/vgscan.c
index a34f3ba..8deafb6 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -50,7 +50,8 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	persistent_filter_wipe(cmd->filter);
+	if (cmd->filter->wipe)
+		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
 
 	_lvmetad = lvmetad_active();


