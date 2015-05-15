From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:37 +0000 (UTC)
Subject: master - lvmpolld: introduce client functionality
Message-ID: <20150515183737.CAC33613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b91e1ea95ec3b1196eade0bbd9f539bf3c7c460a
Commit:        b91e1ea95ec3b1196eade0bbd9f539bf3c7c460a
Parent:        04c77bd8863b071b9e376c76708af6cede596a45
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 18:47:25 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:27 2015 +0200

lvmpolld: introduce client functionality

as of now lvmpolld works as client utility for
querying running instance of lvmpolld server
on metadata, state, etc.

Currently the only request implemented is the '--dump'.
It prints out full lvmpolld state (mimics lvmdump -p command).
---
 WHATS_NEW                        |    1 +
 daemons/lvmpolld/lvmpolld-core.c |  231 ++++++++++++++++++++++++++++++++------
 2 files changed, 197 insertions(+), 35 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e92c01a..13a034b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  add lvmpolld client mode for querying running server instance for status info.
   Fix some libdaemon socket creation and reuse error paths.
   Daemons (libdaemon) support exit on idle also in non-systemd environment.
   Provide make dist and make rpm targets
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index ad6f5f7..5385a04 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -18,6 +18,7 @@
 #include "daemon-server.h"
 #include "daemon-log.h"
 
+#include <getopt.h>
 #include <poll.h>
 #include <wait.h>
 
@@ -61,21 +62,23 @@ static const char *_strerror_r(int errnum, struct lvmpolld_thread_data *data)
 #endif
 }
 
-static void usage(const char *prog, FILE *file)
+static void _usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n\n"
+		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n"
+		"%s --dump [-s path]\n"
 		"   -V       Show version info\n"
 		"   -h       Show this help information\n"
 		"   -f       Don't fork, run in the foreground\n"
+		"   --dump   Dump full lvmpolld state\n"
 		"   -l       Logging message level (-l {all|wire|debug})\n"
 		"   -p       Set path to the pidfile\n"
-		"   -s       Set path to the socket to listen on\n"
+		"   -s       Set path to the communication socket\n"
 		"   -B       Path to lvm2 binary\n"
-		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog);
+		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog, prog);
 }
 
-static int init(struct daemon_state *s)
+static int _init(struct daemon_state *s)
 {
 	struct lvmpolld_state *ls = s->private;
 	ls->log = s->log;
@@ -109,35 +112,35 @@ static int init(struct daemon_state *s)
 	return 1;
 }
 
-static void lvmpolld_stores_lock(struct lvmpolld_state *ls)
+static void _lvmpolld_stores_lock(struct lvmpolld_state *ls)
 {
 	pdst_lock(ls->id_to_pdlv_poll);
 	pdst_lock(ls->id_to_pdlv_abort);
 }
 
-static void lvmpolld_stores_unlock(struct lvmpolld_state *ls)
+static void _lvmpolld_stores_unlock(struct lvmpolld_state *ls)
 {
 	pdst_unlock(ls->id_to_pdlv_abort);
 	pdst_unlock(ls->id_to_pdlv_poll);
 }
 
-static void lvmpolld_global_lock(struct lvmpolld_state *ls)
+static void _lvmpolld_global_lock(struct lvmpolld_state *ls)
 {
-	lvmpolld_stores_lock(ls);
+	_lvmpolld_stores_lock(ls);
 
 	pdst_locked_lock_all_pdlvs(ls->id_to_pdlv_poll);
 	pdst_locked_lock_all_pdlvs(ls->id_to_pdlv_abort);
 }
 
-static void lvmpolld_global_unlock(struct lvmpolld_state *ls)
+static void _lvmpolld_global_unlock(struct lvmpolld_state *ls)
 {
 	pdst_locked_unlock_all_pdlvs(ls->id_to_pdlv_abort);
 	pdst_locked_unlock_all_pdlvs(ls->id_to_pdlv_poll);
 
-	lvmpolld_stores_unlock(ls);
+	_lvmpolld_stores_unlock(ls);
 }
 
-static int fini(struct daemon_state *s)
+static int _fini(struct daemon_state *s)
 {
 	int done;
 	const struct timespec t = { .tv_nsec = 250000000 }; /* .25 sec */
@@ -147,18 +150,18 @@ static int fini(struct daemon_state *s)
 
 	DEBUGLOG(s, "sending cancel requests");
 
-	lvmpolld_global_lock(ls);
+	_lvmpolld_global_lock(ls);
 	pdst_locked_send_cancel(ls->id_to_pdlv_poll);
 	pdst_locked_send_cancel(ls->id_to_pdlv_abort);
-	lvmpolld_global_unlock(ls);
+	_lvmpolld_global_unlock(ls);
 
 	DEBUGLOG(s, "waiting for background threads to finish");
 
 	while(1) {
-		lvmpolld_stores_lock(ls);
+		_lvmpolld_stores_lock(ls);
 		done = !pdst_locked_get_active_count(ls->id_to_pdlv_poll) &&
 		       !pdst_locked_get_active_count(ls->id_to_pdlv_abort);
-		lvmpolld_stores_unlock(ls);
+		_lvmpolld_stores_unlock(ls);
 		if (done)
 			break;
 		nanosleep(&t, NULL);
@@ -166,10 +169,10 @@ static int fini(struct daemon_state *s)
 
 	DEBUGLOG(s, "destroying internal data structures");
 
-	lvmpolld_stores_lock(ls);
+	_lvmpolld_stores_lock(ls);
 	pdst_locked_destroy_all_pdlvs(ls->id_to_pdlv_poll);
 	pdst_locked_destroy_all_pdlvs(ls->id_to_pdlv_abort);
-	lvmpolld_stores_unlock(ls);
+	_lvmpolld_stores_unlock(ls);
 
 	pdst_destroy(ls->id_to_pdlv_poll);
 	pdst_destroy(ls->id_to_pdlv_abort);
@@ -199,12 +202,12 @@ static void update_idle_state(struct lvmpolld_state *ls)
 	if (!ls->idle)
 		return;
 
-	lvmpolld_stores_lock(ls);
+	_lvmpolld_stores_lock(ls);
 
 	ls->idle->is_idle = !pdst_locked_get_active_count(ls->id_to_pdlv_poll) &&
 			    !pdst_locked_get_active_count(ls->id_to_pdlv_abort);
 
-	lvmpolld_stores_unlock(ls);
+	_lvmpolld_stores_unlock(ls);
 
 	DEBUGLOG(ls, "%s: %s %s%s", PD_LOG_PREFIX, "daemon is", ls->idle->is_idle ? "" : "not ", "idle");
 }
@@ -703,7 +706,7 @@ static response dump_state(client_handle h, struct lvmpolld_state *ls, request r
 
 	buffer_init(b);
 
-	lvmpolld_global_lock(ls);
+	_lvmpolld_global_lock(ls);
 
 	buffer_append(b, "# Registered polling operations\n\n");
 	buffer_append(b, "poll {\n");
@@ -715,12 +718,12 @@ static response dump_state(client_handle h, struct lvmpolld_state *ls, request r
 	pdst_locked_dump(ls->id_to_pdlv_abort, b);
 	buffer_append(b, "}");
 
-	lvmpolld_global_unlock(ls);
+	_lvmpolld_global_unlock(ls);
 
 	return res;
 }
 
-static response handler(struct daemon_state s, client_handle h, request r)
+static response _handler(struct daemon_state s, client_handle h, request r)
 {
 	struct lvmpolld_state *ls = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
@@ -755,16 +758,149 @@ static int process_timeout_arg(const char *str, unsigned *max_timeouts)
 	return 1;
 }
 
+/* Client functionality */
+typedef int (*action_fn_t) (void *args);
+
+struct log_line_baton {
+	const char *prefix;
+};
+
+daemon_handle _lvmpolld = { .error = 0 };
+
+static daemon_handle _lvmpolld_open(const char *socket)
+{
+	daemon_info lvmpolld_info = {
+		.path = "lvmpolld",
+		.socket = socket ?: DEFAULT_RUN_DIR "/lvmpolld.socket",
+		.protocol = LVMPOLLD_PROTOCOL,
+		.protocol_version = LVMPOLLD_PROTOCOL_VERSION
+	};
+
+	return daemon_open(lvmpolld_info);
+}
+
+static void _log_line(const char *line, void *baton) {
+	struct log_line_baton *b = baton;
+	fprintf(stdout, "%s%s\n", b->prefix, line);
+}
+
+static int printout_raw_response(const char *prefix, const char *msg)
+{
+	struct log_line_baton b = { .prefix = prefix };
+	char *buf;
+	char *pos;
+
+	buf = dm_strdup(msg);
+	pos = buf;
+
+	if (!buf)
+		return 0;
+
+	while (pos) {
+		char *next = strchr(pos, '\n');
+		if (next)
+			*next = 0;
+		_log_line(pos, &b);
+		pos = next ? next + 1 : 0;
+	}
+	dm_free(buf);
+
+	return 1;
+}
+
+/* place all action implementations below */
+
+static int action_dump(void *args __attribute__((unused)))
+{
+	daemon_request req;
+	daemon_reply repl;
+	int r = 0;
+
+	req = daemon_request_make(LVMPD_REQ_DUMP);
+	if (!req.cft) {
+		fprintf(stderr, "Failed to create lvmpolld " LVMPD_REQ_DUMP " request.\n");
+		goto out_req;
+	}
+
+	repl = daemon_send(_lvmpolld, req);
+	if (repl.error) {
+		fprintf(stderr, "Failed to send a request or receive response.\n");
+		goto  out_rep;
+	}
+
+	/*
+	 * This is dumb copy & paste from libdaemon log routines.
+	 */
+	if (!printout_raw_response("  ", repl.buffer.mem)) {
+		fprintf(stderr, "Failed to print out the response.\n");
+		goto  out_rep;
+	}
+
+	r = 1;
+
+out_rep:
+	daemon_reply_destroy(repl);
+out_req:
+	daemon_request_destroy(req);
+
+	return r;
+}
+
+enum action_index {
+	ACTION_DUMP = 0,
+	ACTION_MAX /* keep at the end */
+};
+
+static const action_fn_t const actions[] = { [ACTION_DUMP] = action_dump };
+
+static int _make_action(enum action_index idx, void *args)
+{
+	return idx < ACTION_MAX ? actions[idx](args) : 0;
+}
+
+static int _lvmpolld_client(const char *socket, unsigned action)
+{
+	int r;
+
+	_lvmpolld = _lvmpolld_open(socket);
+
+	if (_lvmpolld.error || _lvmpolld.socket_fd < 0) {
+		fprintf(stderr, "Failed to establish connection with lvmpolld.\n");
+		return 0;
+	}
+
+	r = _make_action(action, NULL);
+
+	daemon_close(_lvmpolld);
+
+	return r ? EXIT_SUCCESS : EXIT_FAILURE;
+}
+
+static int action_idx = ACTION_MAX;
+static struct option long_options[] = {
+	/* Have actions always@the beginning of the array. */
+	{"dump",	no_argument,		&action_idx,	ACTION_DUMP }, /* or an option_index ? */
+
+	/* other options */
+	{"help",	no_argument,		0,		'h' },
+	{"socket",	required_argument,	0,		's' },
+	{"version",	no_argument,		0,		'V' },
+	{0,		0,			0,		0 }
+};
+
 int main(int argc, char *argv[])
 {
-	signed char opt;
+	int opt;
+	int option_index = 0;
+	int client = 0, server = 0;
+	unsigned action = ACTION_MAX;
 	struct timeval timeout;
 	daemon_idle di = { .ptimeout = &timeout };
 	struct lvmpolld_state ls = { .log_config = "" };
 	daemon_state s = {
-		.daemon_fini = fini,
-		.daemon_init = init,
-		.handler = handler,
+		.daemon_fini = _fini,
+		.daemon_init = _init,
+		.handler = _handler,
 		.name = "lvmpolld",
 		.pidfile = getenv("LVM_LVMPOLLD_PIDFILE") ?: LVMPOLLD_PIDFILE,
 		.private = &ls,
@@ -773,28 +909,42 @@ int main(int argc, char *argv[])
 		.socket_path = getenv("LVM_LVMPOLLD_SOCKET") ?: LVMPOLLD_SOCKET,
 	};
 
-	while ((opt = getopt(argc, argv, "?fhVl:p:s:B:t:")) != EOF) {
+	while ((opt = getopt_long(argc, argv, "?fhVl:p:s:B:t:", long_options, &option_index)) != -1) {
 		switch (opt) {
+		case 0 :
+			if (action < ACTION_MAX) {
+				fprintf(stderr, "Can't perform more actions. Action already requested: %s\n",
+					long_options[action].name);
+				_usage(argv[0], stderr);
+				exit(EXIT_FAILURE);
+			}
+			action = action_idx;
+			client = 1;
+			break;
 		case '?':
-			usage(argv[0], stderr);
-			exit(0);
+			_usage(argv[0], stderr);
+			exit(EXIT_SUCCESS);
 		case 'B': /* --binary */
 			ls.lvm_binary = optarg;
+			server = 1;
 			break;
 		case 'V':
 			printf("lvmpolld version: " LVM_VERSION "\n");
-			exit(1);
+			exit(EXIT_SUCCESS);
 		case 'f':
 			s.foreground = 1;
+			server = 1;
 			break;
 		case 'h':
-			usage(argv[0], stdout);
-			exit(0);
+			_usage(argv[0], stdout);
+			exit(EXIT_SUCCESS);
 		case 'l':
 			ls.log_config = optarg;
+			server = 1;
 			break;
 		case 'p':
 			s.pidfile = optarg;
+			server = 1;
 			break;
 		case 's': /* --socket */
 			s.socket_path = optarg;
@@ -802,16 +952,27 @@ int main(int argc, char *argv[])
 		case 't': /* --timeout in seconds */
 			if (!process_timeout_arg(optarg, &di.max_timeouts)) {
 				fprintf(stderr, "Invalid value of timeout parameter");
-				exit(1);
+				exit(EXIT_FAILURE);
 			}
 			/* 0 equals to wait indefinitely */
 			if (di.max_timeouts)
 				s.idle = ls.idle = &di;
+			server = 1;
 			break;
 		}
 	}
 
+	if (client && server) {
+		fprintf(stderr, "Invalid combination of client and server parameters.\n\n");
+		_usage(argv[0], stdout);
+		exit(EXIT_FAILURE);
+	}
+
+	if (client)
+		return _lvmpolld_client(s.socket_path, action);
+
+	/* Server */
 	daemon_start(s);
 
-	return 0;
+	return EXIT_SUCCESS;
 }


