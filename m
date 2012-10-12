From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 08:25:21 +0000 (UTC)
Subject: master - cleanup: fix compiler warnings
Message-ID: <20121012082521.7AEB2A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ee071705b2c35e1132f39f5731861c831a1bb6b
Commit:        9ee071705b2c35e1132f39f5731861c831a1bb6b
Parent:        ee3cfa41843b0af1ef220ecf8bf6db82676af8c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 10:15:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 10:25:07 2012 +0200

cleanup: fix compiler warnings

remove unused vars
move var declarations into the front of functions.
fix some sign warnings
---
 daemons/lvmetad/lvmetad-core.c   |    1 -
 lib/cache/lvmetad.c              |   12 ++++++------
 lib/commands/toolcontext.c       |    4 +++-
 lib/metadata/metadata.c          |    2 +-
 lib/metadata/raid_manip.c        |    4 +---
 libdaemon/client/config-util.c   |   21 ++++++++++++++-------
 libdaemon/client/daemon-client.c |   13 ++++++++++---
 libdaemon/server/daemon-log.c    |   23 ++++++++++++++++-------
 libdaemon/server/daemon-server.c |    5 +++--
 9 files changed, 54 insertions(+), 31 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 99ae99f..8540273 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1147,7 +1147,6 @@ int main(int argc, char *argv[])
 	signed char opt;
 	daemon_state s = { .private = NULL };
 	lvmetad_state ls;
-	int _restart = 0;
 	int _socket_override = 1;
 
 	s.name = "lvmetad";
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 18794be..5d211c6 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -66,13 +66,16 @@ void lvmetad_set_active(int active)
 
 void lvmetad_set_token(const struct dm_config_value *filter)
 {
+	int ft = 0;
+
 	if (_lvmetad_token)
 		dm_free(_lvmetad_token);
-	int ft = 0;
+
 	while (filter && filter->type == DM_CFG_STRING) {
 		ft = calc_crc(ft, (const uint8_t *) filter->v.str, strlen(filter->v.str));
 		filter = filter->next;
 	}
+
 	if (!dm_asprintf(&_lvmetad_token, "filter:%u", ft))
 		log_warn("WARNING: Failed to set lvmetad token. Out of memory?");
 }
@@ -84,7 +87,7 @@ void lvmetad_set_socket(const char *sock)
 
 static daemon_reply _lvmetad_send(const char *id, ...);
 
-static int _token_update()
+static int _token_update(void)
 {
 	daemon_reply repl = _lvmetad_send("token_update", NULL);
 
@@ -101,7 +104,7 @@ static int _token_update()
 static daemon_reply _lvmetad_send(const char *id, ...)
 {
 	va_list ap;
-	daemon_reply repl, token_set;
+	daemon_reply repl;
 	daemon_request req;
 	int try = 0;
 
@@ -128,7 +131,6 @@ retry:
 		}
 	}
 
-out:
 	return repl;
 }
 
@@ -589,7 +591,6 @@ static int _extract_mda(struct metadata_area *mda, void *baton)
 {
 	struct _extract_mda_baton *b = baton;
 	struct dm_config_node *cn;
-	int result = 0;
 	char id[32];
 
 	if (!mda->ops->mda_export_text) /* do nothing */
@@ -651,7 +652,6 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	char uuid[64];
 	daemon_reply reply;
 	struct lvmcache_info *info;
-	const char *mdas = NULL;
 	struct dm_config_tree *pvmeta, *vgmeta;
 	const char *status;
 	int result;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c5e0ee3..5177f41 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -236,6 +236,7 @@ static int _process_config(struct cmd_context *cmd)
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	int64_t pv_min_kb;
+	const char *lvmetad_socket;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -400,7 +401,8 @@ static int _process_config(struct cmd_context *cmd)
 				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
 
 	lvmetad_disconnect();
-	const char *lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
+
+	lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
 	if (!lvmetad_socket)
 		lvmetad_socket = DEFAULT_RUN_DIR "/lvmetad.socket";
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 220e0c1..5a633b6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2943,7 +2943,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
-	int seqno = 0;
+	unsigned seqno = 0;
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 98a7db3..c7910e8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1136,7 +1136,6 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs)
 {
-	const char *old_name;
 	struct lv_list *lvl;
 	struct dm_list removal_list, data_list;
 	struct cmd_context *cmd = lv->vg->cmd;
@@ -1207,7 +1206,6 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	dm_list_iterate_items(lvl, &data_list)
 		break;
 
-	old_name = lvl->lv->name;
 	lvl->lv->name = split_name;
 
 	if (!vg_write(lv->vg)) {
@@ -1317,7 +1315,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		break;
 	}
 
-	if (s >= seg->area_count) {
+	if (s >= (int) seg->area_count) {
 		log_error("Unable to find image to satisfy request");
 		return 0;
 	}
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 30fc4f8..8aa9ed2 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -23,7 +23,7 @@
 
 int buffer_append_vf(struct buffer *buf, va_list ap)
 {
-	char *append, *old;
+	char *append;
 	char *next;
 	int keylen;
 
@@ -60,10 +60,13 @@ fail:
 
 int buffer_append_f(struct buffer *buf, ...)
 {
+	int res;
 	va_list ap;
+
 	va_start(ap, buf);
-	int res = buffer_append_vf(buf, ap);
+	res = buffer_append_vf(buf, ap);
 	va_end(ap);
+
 	return res;
 }
 
@@ -203,10 +206,12 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 {
 	const char *next;
 	struct dm_config_node *first = NULL;
+	struct dm_config_node *cn;
+	const char *fmt, *key;
 
 	while ((next = va_arg(ap, char *))) {
-		struct dm_config_node *cn = NULL;
-		const char *fmt = strchr(next, '=');
+		cn = NULL;
+		fmt = strchr(next, '=');
 
 		if (!fmt) {
 			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
@@ -214,7 +219,7 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 		}
 		fmt += 2;
 
-		char *key = dm_pool_strdup(cft->mem, next);
+		key = dm_pool_strdup(cft->mem, next);
 		*strchr(key, '=') = 0;
 
 		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
@@ -250,10 +255,13 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 					 struct dm_config_node *pre_sib,
 					 ...)
 {
+	struct dm_config_node *res;
 	va_list ap;
+
 	va_start(ap, pre_sib);
-	struct dm_config_node *res = config_make_nodes_v(cft, parent, pre_sib, ap);
+	res = config_make_nodes_v(cft, parent, pre_sib, ap);
 	va_end(ap);
+
 	return res;
 }
 
@@ -280,7 +288,6 @@ int buffer_realloc(struct buffer *buf, int needed)
 int buffer_append(struct buffer *buf, const char *string)
 {
 	int len = strlen(string);
-	char *new;
 
 	if (buf->allocated - buf->used <= len)
 		buffer_realloc(buf, len + 1);
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 107882b..c4422d6 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -71,9 +71,10 @@ error:
 
 daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
+	struct buffer buffer;
 	daemon_reply reply = { .cft = NULL, .error = 0 };
 	assert(h.socket_fd >= 0);
-	struct buffer buffer = rq.buffer;
+	buffer = rq.buffer;
 
 	if (!buffer.mem)
 		dm_config_write_node(rq.cft->root, buffer_line, &buffer);
@@ -120,10 +121,13 @@ daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 
 daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
 {
+	daemon_reply r;
 	va_list ap;
+
 	va_start(ap, id);
-	daemon_reply r = daemon_send_simple_v(h, id, ap);
+	r = daemon_send_simple_v(h, id, ap);
 	va_end(ap);
+
 	return r;
 }
 
@@ -165,10 +169,13 @@ int daemon_request_extend_v(daemon_request r, va_list ap)
 
 int daemon_request_extend(daemon_request r, ...)
 {
+	int res;
 	va_list ap;
+
 	va_start(ap, r);
-	int res = daemon_request_extend_v(r, ap);
+	res = daemon_request_extend_v(r, ap);
 	va_end(ap);
+
 	return res;
 }
 
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index b31bb4e..1e1c9e0 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -10,15 +10,18 @@ struct backend {
 
 static void log_syslog(log_state *s, void **state, int type, const char *message)
 {
+	int prio;
+
 	if (!*state) { /* initialize */
 		*state = (void *)1;
 		openlog(s->name, LOG_PID, LOG_DAEMON);
 	}
-	int prio = LOG_DEBUG;
+
 	switch (type) {
 	case DAEMON_LOG_INFO: prio = LOG_INFO; break;
 	case DAEMON_LOG_WARN: prio = LOG_WARNING; break;
 	case DAEMON_LOG_FATAL: prio = LOG_CRIT; break;
+	default: prio = LOG_DEBUG; break;
 	}
 
 	syslog(prio, "%s", message);
@@ -26,12 +29,14 @@ static void log_syslog(log_state *s, void **state, int type, const char *message
 
 static void log_stderr(log_state *s, void **state, int type, const char *message)
 {
-	const char *prefix = "";
+	const char *prefix;
+
 	switch (type) {
 	case DAEMON_LOG_INFO: prefix = "I: "; break;
 	case DAEMON_LOG_WARN: prefix = "W: " ; break;
-	case DAEMON_LOG_ERROR:
+	case DAEMON_LOG_ERROR: /* fall through */
 	case DAEMON_LOG_FATAL: prefix = "E: " ; break;
+	default: prefix = ""; break;
 	}
 
 	fprintf(stderr, "%s%s\n", prefix, message);
@@ -88,21 +93,25 @@ static int _log_line(const char *line, void *baton) {
 
 void daemon_log_cft(log_state *s, int type, const char *prefix, const struct dm_config_node *n)
 {
+	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
+
 	if (!_type_interesting(s, type))
 		return;
 
-	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
 	dm_config_write_node(n, &_log_line, &b);
 }
 
 void daemon_log_multi(log_state *s, int type, const char *prefix, const char *msg)
 {
+	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
+	char *buf;
+	char *pos;
+
 	if (!_type_interesting(s, type))
 		return;
 
-	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
-	char *buf = dm_strdup(msg);
-	char *pos = buf;
+	buf = dm_strdup(msg);
+	pos = buf;
 
 	if (!buf)
 		return; /* _0 */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 051e7c2..b02621f 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -356,13 +356,13 @@ struct thread_baton {
 static response builtin_handler(daemon_state s, client_handle h, request r)
 {
 	const char *rq = daemon_request_str(r, "request", "NONE");
+	response res = { .error = EPROTO };
 
 	if (!strcmp(rq, "hello")) {
 		return daemon_reply_simple("OK", "protocol = %s", s.protocol ?: "default",
 					   "version = %" PRId64, (int64_t) s.protocol_version, NULL);
 	}
 
-	response res = { .error = EPROTO };
 	buffer_init(&res.buffer);
 	return res;
 }
@@ -444,6 +444,8 @@ static int handle_connect(daemon_state s)
 void daemon_start(daemon_state s)
 {
 	int failed = 0;
+	log_state _log = { { 0 } };
+
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
 	 * some glibc (on some distributions it takes over 100MB). Some daemons
@@ -459,7 +461,6 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		_daemonise();
 
-	log_state _log = { { 0 } };
 	s.log = &_log;
 	s.log->name = s.name;
 


