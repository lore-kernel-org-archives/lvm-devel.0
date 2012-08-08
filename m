From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Aug 2012 07:45:18 +0000 (UTC)
Subject: master - libdaemon: Draft logging infrastructure.
Message-ID: <20120808074518.542903457@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b61be643701d05bb12e0b2e32085f312a1f121bf
Commit:        b61be643701d05bb12e0b2e32085f312a1f121bf
Parent:        7ecccc3099c854bd9a993b360974a9f52a746131
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 8 09:41:01 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 8 09:44:19 2012 +0200

libdaemon: Draft logging infrastructure.

- logging is not controlled by "levels" but by "types"; types are
  independent of each other... implementation of the usual "log level"
  user-level semantics can be simply done on top; the immediate
  application is enabling/disabling wire traffic logging independently
  of other debug data, since the former is rather bulky and can easily
  obscure almost everything else
- all logs go to "outlets", of which we currently have 2: syslog and
  stderr; which "types" go to which "outlets" is entirely configurable
---
 daemons/lvmetad/lvmetad-core.c   |   79 +++++++++------------
 libdaemon/server/Makefile.in     |    2 +-
 libdaemon/server/daemon-log.c    |  143 ++++++++++++++++++++++++++++++++++++++
 libdaemon/server/daemon-log.h    |   14 ++++
 libdaemon/server/daemon-server.c |   23 ++++--
 libdaemon/server/daemon-server.h |   38 ++++++++++-
 test/lib/aux.sh                  |    2 +-
 7 files changed, 245 insertions(+), 56 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0b0ec73..d06ff46 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -17,6 +17,7 @@
 #include "configure.h"
 #include "daemon-shared.h"
 #include "daemon-server.h"
+#include "daemon-log.h"
 
 #include <assert.h>
 #include <pthread.h>
@@ -25,6 +26,9 @@
 #include <unistd.h>
 
 typedef struct {
+	log_state *log; /* convenience */
+	const char *debug_config;
+
 	struct dm_hash_table *pvid_to_pvmeta;
 	struct dm_hash_table *device_to_pvid; /* shares locks with above */
 
@@ -40,26 +44,6 @@ typedef struct {
 	} lock;
 } lvmetad_state;
 
-__attribute__ ((format(printf, 1, 2)))
-static void debug(const char *fmt, ...) {
-	va_list ap;
-	va_start(ap, fmt);
-	fprintf(stderr, "[D %lu] ", pthread_self());
-	vfprintf(stderr, fmt, ap);
-	va_end(ap);
-	fflush(stderr);
-}
-
-static int debug_cft_line(const char *line, void *baton) {
-	fprintf(stderr, "| %s\n", line);
-	return 0;
-}
-
-static void debug_cft(const char *id, struct dm_config_node *n) {
-	debug("%s\n", id);
-	dm_config_write_node(n, &debug_cft_line, NULL);
-}
-
 static void lock_pvid_to_pvmeta(lvmetad_state *s) {
 	pthread_mutex_lock(&s->lock.pvid_to_pvmeta); }
 static void unlock_pvid_to_pvmeta(lvmetad_state *s) {
@@ -98,7 +82,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 			return NULL;
 		}
 	}
-	// debug("lock VG %s\n", id);
+	DEBUG(s, "locking VG %s", id);
 	pthread_mutex_lock(vg);
 	cft = dm_hash_lookup(s->vgid_to_metadata, id);
 	unlock_vgid_to_metadata(s);
@@ -108,7 +92,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 static void unlock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 
-	// debug("unlock VG %s\n", id);
+	DEBUG(s, "unlocking VG %s", id);
 	lock_vgid_to_metadata(s); /* someone might be changing the s->lock.vg structure right
 				   * now, so avoid stepping on each other's toes */
 	if ((vg = dm_hash_lookup(s->lock.vg, id)))
@@ -410,7 +394,7 @@ static response pv_lookup(lvmetad_state *s, request r)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
 
 	if (!pvid) {
-		debug("pv_lookup: could not find device %" PRIu64 "\n", devt);
+		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
 		return daemon_reply_simple("unknown", "reason = %s", "device not found", NULL);
@@ -507,7 +491,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
 	const char *name = daemon_request_str(r, "name", NULL);
 
-	debug("vg_lookup: uuid = %s, name = %s\n", uuid, name);
+	DEBUG(s, "vg_lookup: uuid = %s, name = %s", uuid, name);
 
 	if (!uuid || !name) {
 		lock_vgid_to_metadata(s);
@@ -518,7 +502,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 		unlock_vgid_to_metadata(s);
 	}
 
-	debug("vg_lookup: updated uuid = %s, name = %s\n", uuid, name);
+	DEBUG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
 
 	if (!uuid)
 		return daemon_reply_simple("unknown", "reason = %s", "VG not found", NULL);
@@ -596,7 +580,7 @@ static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
 		result = compare_config(a->child, b->child);
 
 	if (result) {
-		debug("config inequality at %s / %s\n", a->key, b->key);
+		// DEBUG("config inequality at %s / %s", a->key, b->key);
 		return result;
 	}
 
@@ -642,7 +626,7 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
 			goto out;
 
-		debug("remap PV %s to VG %s\n", pvid, vgid);
+		DEBUG(s, "moving PV %s to VG %s", pvid, vgid);
 	}
 
 	for (n = dm_hash_get_first(to_check); n;
@@ -712,7 +696,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
 	}
 
 	if (missing) {
-		debug("nuking VG %s\n", vgid);
+		DEBUG(s, "removing empty VG %s", vgid);
 		remove_metadata(s, vgid, 0);
 	}
 
@@ -758,17 +742,17 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 		retval = 1;
 		if (compare_config(metadata, old->root))
 			retval = 0;
-		debug("Not updating metadata for %s at %d (%s)\n", _vgid, haveseq,
+		DEBUG(s, "Not updating metadata for %s at %d (%s)", _vgid, haveseq,
 		      retval ? "ok" : "MISMATCH");
 		if (!retval) {
-			debug_cft("OLD: ", old->root);
-			debug_cft("NEW: ", metadata);
+			DEBUG_cft(s, "OLD: ", old->root);
+			DEBUG_cft(s, "NEW: ", metadata);
 		}
 		goto out;
 	}
 
 	if (seq < haveseq) {
-		debug("Refusing to update metadata for %s@%d to %d\n", _vgid, haveseq, seq);
+		DEBUG(s, "Refusing to update metadata for %s (at %d) to %d", _vgid, haveseq, seq);
 		/* TODO: notify the client that their metadata is out of date? */
 		retval = 1;
 		goto out;
@@ -776,27 +760,27 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	if (!(cft = dm_config_create()) ||
 	    !(cft->root = dm_config_clone_node(cft, metadata, 0))) {
-		debug("Out of memory\n");
+		ERROR(s, "Out of memory");
 		goto out;
 	}
 
 	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid || !name) {
-		debug("Name '%s' or uuid '%s' missing!\n", name, vgid);
+		DEBUG(s, "Name '%s' or uuid '%s' missing!", name, vgid);
 		goto out;
 	}
 
 	lock_pvid_to_vgid(s);
 
 	if (haveseq >= 0 && haveseq < seq) {
-		debug("Updating metadata for %s at %d to %d\n", _vgid, haveseq, seq);
+		INFO(s, "Updating metadata for %s@%d to %d", _vgid, haveseq, seq);
 		/* temporarily orphan all of our PVs */
 		remove_metadata(s, vgid, 1);
 	}
 
 	lock_vgid_to_metadata(s);
-	debug("Mapping %s to %s\n", vgid, name);
+	DEBUG(s, "Mapping %s to %s", vgid, name);
 
 	retval = ((cfgname = dm_pool_strdup(dm_config_memory(cft), name)) &&
 		  dm_hash_insert(s->vgid_to_metadata, vgid, cft) &&
@@ -820,7 +804,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	int64_t device = daemon_request_int(r, "device", 0);
 	struct dm_config_tree *pvmeta;
 
-	debug("pv_gone: %s / %" PRIu64 "\n", pvid, device);
+	DEBUG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
 	lock_pvid_to_pvmeta(s);
 	if (!pvid && device > 0)
@@ -830,7 +814,7 @@ static response pv_gone(lvmetad_state *s, request r)
 		return daemon_reply_simple("unknown", "reason = %s", "device not in cache", NULL);
 	}
 
-	debug("pv_gone (updated): %s / %" PRIu64 "\n", pvid, device);
+	DEBUG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
@@ -866,7 +850,7 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
 		return daemon_reply_simple("failed", "reason = %s", "need PV device number", NULL);
 
-	debug("pv_found %s, vgid = %s, device = %" PRIu64 "\n", pvid, vgid, device);
+	DEBUG(s, "pv_found %s, vgid = %s, device = %" PRIu64, pvid, vgid, device);
 
 	lock_pvid_to_pvmeta(s);
 
@@ -895,7 +879,7 @@ static response pv_found(lvmetad_state *s, request r)
 	if (metadata) {
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
-		debug("obtained vgid = %s, vgname = %s\n", vgid, vgname);
+		DEBUG(s, "obtained vgid = %s, vgname = %s", vgid, vgname);
 		if (!vgname)
 			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
@@ -959,7 +943,7 @@ static response vg_remove(lvmetad_state *s, request r)
 	if (!vgid)
 		return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
 
-	fprintf(stderr, "vg_remove: %s\n", vgid);
+	DEBUG(s, "vg_remove: %s", vgid);
 
 	lock_pvid_to_vgid(s);
 	remove_metadata(s, vgid, 1);
@@ -1009,6 +993,7 @@ static int init(daemon_state *s)
 {
 	pthread_mutexattr_t rec;
 	lvmetad_state *ls = s->private;
+	ls->log = s->log;
 
 	ls->pvid_to_pvmeta = dm_hash_create(32);
 	ls->device_to_pvid = dm_hash_create(32);
@@ -1023,7 +1008,10 @@ static int init(daemon_state *s)
 	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
 
-	debug("initialised state: vgid_to_metadata = %p\n", ls->vgid_to_metadata);
+	/* Set up stderr logging depending on the -d option. */
+	daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->debug_config, 1);
+
+	DEBUG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
 	if (!ls->pvid_to_vgid || !ls->vgid_to_metadata)
 		return 0;
 
@@ -1038,7 +1026,7 @@ static int fini(daemon_state *s)
 	lvmetad_state *ls = s->private;
 	struct dm_hash_node *n = dm_hash_get_first(ls->vgid_to_metadata);
 
-	debug("fini\n");
+	DEBUG(s, "fini");
 	while (n) {
 		dm_config_destroy(dm_hash_get_data(ls->vgid_to_metadata, n));
 		n = dm_hash_get_next(ls->vgid_to_metadata, n);
@@ -1094,12 +1082,11 @@ int main(int argc, char *argv[])
 	if (!s.socket_path)
 		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
 	s.pidfile = LVMETAD_PIDFILE;
-        s.log_level = 0;
 	s.protocol = "lvmetad";
 	s.protocol_version = 1;
 
 	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVdRs:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVd:Rs:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1114,7 +1101,7 @@ int main(int argc, char *argv[])
 			s.foreground = 1;
 			break;
 		case 'd':
-			s.log_level++;
+			ls.debug_config = optarg;
 			break;
 		case 's': // --socket
 			s.socket_path = optarg;
diff --git a/libdaemon/server/Makefile.in b/libdaemon/server/Makefile.in
index 245a19d..1c4a38e 100644
--- a/libdaemon/server/Makefile.in
+++ b/libdaemon/server/Makefile.in
@@ -15,7 +15,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 LIB_STATIC = libdaemonserver.a
-SOURCES = daemon-server.c
+SOURCES = daemon-server.c daemon-log.c
 
 include $(top_builddir)/make.tmpl
 
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
new file mode 100644
index 0000000..caa40cb
--- /dev/null
+++ b/libdaemon/server/daemon-log.c
@@ -0,0 +1,143 @@
+#include "daemon-server.h"
+#include "daemon-log.h"
+#include <syslog.h>
+#include "assert.h"
+
+struct backend {
+	int id;
+	void (*log)(log_state *s, void **state, int type, const char *message);
+};
+
+static void log_syslog(log_state *s, void **state, int type, const char *message)
+{
+	if (!*state) { /* initialize */
+		*state = (void *)1;
+		openlog(s->name, LOG_PID, LOG_DAEMON);
+	}
+	int prio = LOG_DEBUG;
+	switch (type) {
+	case DAEMON_LOG_INFO: prio = LOG_INFO; break;
+	case DAEMON_LOG_WARN: prio = LOG_WARNING; break;
+	case DAEMON_LOG_FATAL: prio = LOG_CRIT; break;
+	}
+
+	syslog(prio, "%s", message);
+}
+
+static void log_stderr(log_state *s, void **state, int type, const char *message)
+{
+	const char *prefix = "";
+	switch (type) {
+	case DAEMON_LOG_INFO: prefix = "I: "; break;
+	case DAEMON_LOG_WARN: prefix = "W: " ; break;
+	case DAEMON_LOG_ERROR:
+	case DAEMON_LOG_FATAL: prefix = "E: " ; break;
+	}
+
+	fprintf(stderr, "%s%s\n", prefix, message);
+}
+
+struct backend backend[] = {
+	{ DAEMON_LOG_OUTLET_SYSLOG, log_syslog },
+	{ DAEMON_LOG_OUTLET_STDERR, log_stderr },
+	{ 0, 0 }
+};
+
+void daemon_log(log_state *s, int type, const char *message) {
+	int i = 0;
+	while ( backend[i].id ) {
+		if ( (s->log_config[type] & backend[i].id) == backend[i].id )
+			backend[i].log( s, &s->backend_state[i], type, message );
+		++ i;
+	}
+}
+
+void daemon_logf(log_state *s, int type, const char *fmt, ...) {
+	va_list ap;
+	va_start(ap, fmt);
+	char *buf;
+	if (dm_vasprintf(&buf, fmt, ap) < 0)
+		return; /* _0 */
+	daemon_log(s, type, buf);
+}
+
+struct log_line_baton {
+	log_state *s;
+	int type;
+	const char *prefix;
+};
+
+static int _log_line(const char *line, void *baton) {
+	struct log_line_baton *b = baton;
+	daemon_logf(b->s, b->type, "%s%s", b->prefix, line);
+	return 0;
+}
+
+void daemon_log_cft(log_state *s, int type, const char *prefix, const struct dm_config_node *n)
+{
+	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
+	dm_config_write_node(n, &_log_line, &b);
+}
+
+void daemon_log_multi(log_state *s, int type, const char *prefix, const char *msg)
+{
+	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
+	char *buf = dm_strdup(msg);
+	char *pos = buf;
+
+	if (!buf)
+		return; /* _0 */
+
+	while (pos) {
+		char *next = strchr(pos, '\n');
+		if (next)
+			*next = 0;
+		_log_line(pos, &b);
+		pos = next ? next + 1 : 0;
+	}
+}
+
+void daemon_log_enable(log_state *s, int outlet, int type, int enable)
+{
+	assert(type < 32);
+	if (enable)
+		s->log_config[type] |= outlet;
+	else
+		s->log_config[type] &= ~outlet;
+}
+
+static int _parse_one(log_state *s, int outlet, const char *type, int enable)
+{
+	int i;
+	if (!strcmp(type, "all"))
+		for (i = 0; i < 32; ++i)
+			daemon_log_enable(s, outlet, i, enable);
+	else if (!strcmp(type, "wire"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_WIRE, enable);
+	else if (!strcmp(type, "debug"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_DEBUG, enable);
+	else
+		return 0;
+
+	return 1;
+}
+
+int daemon_log_parse(log_state *s, int outlet, const char *types, int enable)
+{
+	char *buf = dm_strdup(types);
+	char *pos = buf;
+
+	if (!buf)
+		return 0;
+
+	while (pos) {
+		char *next = strchr(pos, ',');
+		if (next)
+			*next = 0;
+		if (!_parse_one(s, outlet, pos, enable))
+			return 0;
+		pos = next ? next + 1 : 0;
+	}
+
+	return 1;
+}
diff --git a/libdaemon/server/daemon-log.h b/libdaemon/server/daemon-log.h
new file mode 100644
index 0000000..17d8007
--- /dev/null
+++ b/libdaemon/server/daemon-log.h
@@ -0,0 +1,14 @@
+enum { DAEMON_LOG_FATAL = 0 /* usually preceding daemon death */
+     , DAEMON_LOG_ERROR = 1 /* something serious has happened */
+     , DAEMON_LOG_WARN = 2 /* something unusual has happened */
+     , DAEMON_LOG_INFO = 3 /* thought you might be interested */
+     , DAEMON_LOG_WIRE = 4 /* dump traffic on client sockets */
+     , DAEMON_LOG_DEBUG = 5 /* unsorted debug stuff */
+     };
+
+#define DEBUG(s, x...) daemon_logf((s)->log, DAEMON_LOG_DEBUG, x)
+#define DEBUG_cft(s, i, n) daemon_log_cft((s)->log, DAEMON_LOG_DEBUG, i, n)
+#define WARN(s, x...) daemon_logf((s)->log, DAEMON_LOG_WARN, x)
+#define INFO(s, x...) daemon_logf((s)->log, DAEMON_LOG_INFO, x)
+#define ERROR(s, x...) daemon_logf((s)->log, DAEMON_LOG_ERROR, x)
+#define FATAL(s, x...) daemon_logf((s)->log, DAEMON_LOG_FATAL, x)
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 5ca9231..c69da36 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -12,6 +12,7 @@
 
 #include "daemon-shared.h"
 #include "daemon-server.h"
+#include "daemon-log.h"
 
 #include <dlfcn.h>
 #include <errno.h>
@@ -26,7 +27,7 @@
 #include <unistd.h>
 #include <signal.h>
 
-#include <syslog.h>
+#include <syslog.h> /* FIXME. For the global closelog(). */
 
 #if 0
 /* Create a device monitoring thread. */
@@ -391,6 +392,7 @@ static void *client_thread(void *baton)
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
 
+		daemon_log_cft(b->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 		res = builtin_handler(b->s, b->client, req);
 
 		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
@@ -407,6 +409,7 @@ static void *client_thread(void *baton)
 			dm_config_destroy(req.cft);
 		dm_free(req.buffer);
 
+		daemon_log_multi(b->s.log, DAEMON_LOG_WIRE, "-> ", res.buffer);
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
 
 		free(res.buffer);
@@ -462,8 +465,13 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		_daemonise();
 
-	/* TODO logging interface should be somewhat more elaborate */
-	openlog(s.name, LOG_PID, LOG_DAEMON);
+	log_state _log = { { 0 } };
+	s.log = &_log;
+	s.log->name = s.name;
+
+	/* Log important things to syslog by default. */
+	daemon_log_enable(s.log, DAEMON_LOG_OUTLET_SYSLOG, DAEMON_LOG_FATAL, 1);
+	daemon_log_enable(s.log, DAEMON_LOG_OUTLET_SYSLOG, DAEMON_LOG_ERROR, 1);
 
 	(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
 
@@ -487,7 +495,7 @@ void daemon_start(daemon_state s)
 #ifdef linux
 	/* Systemd has adjusted oom killer for us already */
 	if (s.avoid_oom && !_systemd_activation && !_protect_against_oom_killer())
-		syslog(LOG_ERR, "Failed to protect against OOM killer");
+		ERROR(&s, "Failed to protect against OOM killer");
 #endif
 
 	if (!_systemd_activation && s.socket_path) {
@@ -511,7 +519,7 @@ void daemon_start(daemon_state s)
 			perror("select error");
 		if (FD_ISSET(s.socket_fd, &in))
 			if (!_shutdown_requested && !handle_connect(s))
-				syslog(LOG_ERR, "Failed to handle a client connection.");
+				ERROR(&s, "Failed to handle a client connection.");
 	}
 
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
@@ -522,8 +530,9 @@ void daemon_start(daemon_state s)
 	if (s.daemon_fini)
 		s.daemon_fini(&s);
 
-	syslog(LOG_NOTICE, "%s shutting down", s.name);
-	closelog();
+	INFO(&s, "%s shutting down", s.name);
+
+	closelog(); /* FIXME */
 	remove_lockfile(s.pidfile);
 	if (failed)
 		exit(1);
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index 104dac1..df7ed8e 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -64,6 +64,12 @@ static inline const char *daemon_request_str(request r, const char *path, const
  */
 typedef response (*handle_request)(struct daemon_state s, client_handle h, request r);
 
+typedef struct {
+	uint32_t log_config[32];
+	void *backend_state[32];
+	const char *name;
+} log_state;
+
 typedef struct daemon_state {
 	/*
 	 * The maximal stack size for individual daemon threads. This is
@@ -81,7 +87,6 @@ typedef struct daemon_state {
 	const char *protocol;
 	int protocol_version;
 
-	int log_level;
 	handle_request handler;
 	int (*daemon_init)(struct daemon_state *st);
 	int (*daemon_fini)(struct daemon_state *st);
@@ -89,6 +94,7 @@ typedef struct daemon_state {
 	/* Global runtime info maintained by the framework. */
 	int socket_fd;
 
+	log_state *log;
 	void *private; /* the global daemon state */
 } daemon_state;
 
@@ -119,4 +125,34 @@ daemon_reply daemon_takeover(daemon_info i, daemon_request r);
 /* Call this to request a clean shutdown of the daemon. Async safe. */
 void daemon_stop(void);
 
+enum { DAEMON_LOG_OUTLET_SYSLOG = 1,
+       DAEMON_LOG_OUTLET_STDERR = 2,
+       DAEMON_LOG_OUTLET_SOCKET = 4 };
+
+/* Log a message of a given type. */
+void daemon_log(log_state *s, int type, const char *message);
+
+/* Log a config (sub)tree, using a given message type, each line prefixed with "prefix". */
+void daemon_log_cft(log_state *s, int type, const char *prefix,
+                    const struct dm_config_node *n);
+
+/* Log a multi-line block, prefixing each line with "prefix". */
+void daemon_log_multi(log_state *s, int type, const char *prefix, const char *message);
+
+/* Log a formatted message as "type". See also daemon-log.h. */
+void daemon_logf(log_state *s, int type, const char *format, ...);
+
+/*
+ * Configure log_state to send messages of type "type" to the log outlet
+ * "outlet", iff "enable" is true.
+ */
+void daemon_log_enable(log_state *s, int outlet, int type, int enable);
+
+/*
+ * Set up logging on a given outlet using a list of message types (comma
+ * separated) to log using that outlet. The list is expected to look like this,
+ * "info,wire,debug". Returns 0 upon encountering an unknown message type.
+ */
+int daemon_log_parse(log_state *s, int outlet, const char *types, int enable);
+
 #endif
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4128f30..26508cf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -74,7 +74,7 @@ prepare_lvmetad() {
 	lvmconf "devices/md_component_detection = 0"
 
 	echo "preparing lvmetad..."
-	lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" &
+	lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -d wire,debug &
 	echo $! > LOCAL_LVMETAD
 
 	sleep .3


