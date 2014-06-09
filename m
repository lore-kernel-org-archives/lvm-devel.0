From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  9 Jun 2014 00:35:30 +0000 (UTC)
Subject: master - libdaemon: Keep track of client threads, wait before shutdown.
Message-ID: <20140609003530.C438360DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=488f3085279e24af21e870d5a74d0953094552f7
Commit:        488f3085279e24af21e870d5a74d0953094552f7
Parent:        4bb1efe2fbcbd5702836e2c97e9aa3a1eed88847
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jun 9 01:50:57 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 9 01:50:57 2014 +0200

libdaemon: Keep track of client threads, wait before shutdown.

---
 libdaemon/server/daemon-server.c |   67 +++++++++++++++++++++++--------------
 libdaemon/server/daemon-server.h |   10 ++++++
 2 files changed, 52 insertions(+), 25 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 919f7df..0ea3f69 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -395,11 +395,6 @@ end:
 	return res;
 }
 
-struct thread_baton {
-	daemon_state s;
-	client_handle client;
-};
-
 static response builtin_handler(daemon_state s, client_handle h, request r)
 {
 	const char *rq = daemon_request_str(r, "request", "NONE");
@@ -414,17 +409,16 @@ static response builtin_handler(daemon_state s, client_handle h, request r)
 	return res;
 }
 
-static void *client_thread(void *baton)
+static void *client_thread(void *state)
 {
-	struct thread_baton *b = baton;
+	thread_state *ts = state;
 	request req;
 	response res;
 
-	b->client.thread_id = pthread_self();
 	buffer_init(&req.buffer);
 
 	while (1) {
-		if (!buffer_read(b->client.socket_fd, &req.buffer))
+		if (!buffer_read(ts->client.socket_fd, &req.buffer))
 			goto fail;
 
 		req.cft = dm_config_from_string(req.buffer.mem);
@@ -432,12 +426,12 @@ static void *client_thread(void *baton)
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer.mem);
 		else
-			daemon_log_cft(b->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
+			daemon_log_cft(ts->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 
-		res = builtin_handler(b->s, b->client, req);
+		res = builtin_handler(ts->s, ts->client, req);
 
 		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
-			res = b->s.handler(b->s, b->client, req);
+			res = ts->s.handler(ts->s, ts->client, req);
 
 		if (!res.buffer.mem) {
 			if (!dm_config_write_node(res.cft->root, buffer_line, &res.buffer))
@@ -451,54 +445,72 @@ static void *client_thread(void *baton)
 			dm_config_destroy(req.cft);
 		buffer_destroy(&req.buffer);
 
-		daemon_log_multi(b->s.log, DAEMON_LOG_WIRE, "-> ", res.buffer.mem);
-		buffer_write(b->client.socket_fd, &res.buffer);
+		daemon_log_multi(ts->s.log, DAEMON_LOG_WIRE, "-> ", res.buffer.mem);
+		buffer_write(ts->client.socket_fd, &res.buffer);
 
 		buffer_destroy(&res.buffer);
 	}
 fail:
 	/* TODO what should we really do here? */
-	if (close(b->client.socket_fd))
+	if (close(ts->client.socket_fd))
 		perror("close");
 	buffer_destroy(&req.buffer);
-	dm_free(baton);
+	ts->active = 0;
 	return NULL;
 }
 
 static int handle_connect(daemon_state s)
 {
-	struct thread_baton *baton;
+	thread_state *ts;
 	struct sockaddr_un sockaddr;
 	client_handle client = { .thread_id = 0 };
 	socklen_t sl = sizeof(sockaddr);
-	pthread_t tid;
 
 	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
 	if (client.socket_fd < 0)
 		return 0;
 
-	if (!(baton = dm_malloc(sizeof(struct thread_baton)))) {
+	if (!(ts = dm_malloc(sizeof(thread_state)))) {
 		if (close(client.socket_fd))
 			perror("close");
-		ERROR(&s, "Failed to allocate thread baton");
+		ERROR(&s, "Failed to allocate thread state");
 		return 0;
 	}
 
-	baton->s = s;
-	baton->client = client;
+	ts->next = s.threads->next;
+	s.threads->next = ts;
 
-	if (pthread_create(&tid, NULL, client_thread, baton))
-		return 0;
+	ts->active = 1;
+	ts->s = s;
+	ts->client = client;
 
-	pthread_detach(tid);
+	if (pthread_create(&ts->client.thread_id, NULL, client_thread, ts))
+		return 0;
 
 	return 1;
 }
 
+static void reap(daemon_state s, int wait)
+{
+	thread_state *last = s.threads, *ts = last->next;
+	void *rv;
+
+	while (ts) {
+		if (wait || !ts->active) {
+			pthread_join(ts->client.thread_id, &rv);
+			last->next = ts->next;
+			dm_free(ts);
+		} else
+			last = ts;
+		ts = last->next;
+	}
+}
+
 void daemon_start(daemon_state s)
 {
 	int failed = 0;
 	log_state _log = { { 0 } };
+	thread_state _threads = { .next = NULL };
 
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
@@ -517,6 +529,7 @@ void daemon_start(daemon_state s)
 
 	s.log = &_log;
 	s.log->name = s.name;
+	s.threads = &_threads;
 
 	/* Log important things to syslog by default. */
 	daemon_log_enable(s.log, DAEMON_LOG_OUTLET_SYSLOG, DAEMON_LOG_FATAL, 1);
@@ -572,8 +585,12 @@ void daemon_start(daemon_state s)
 		if (FD_ISSET(s.socket_fd, &in))
 			if (!_shutdown_requested && !handle_connect(s))
 				ERROR(&s, "Failed to handle a client connection.");
+		reap(s, 0);
 	}
 
+	INFO(&s, "%s waiting for client threads to finish", s.name);
+	reap(s, 1);
+
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
 	if (!_systemd_activation && s.socket_fd >= 0)
 		if (unlink(s.socket_path))
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index ad41372..a7673d4 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -70,6 +70,8 @@ typedef struct {
 	const char *name;
 } log_state;
 
+struct thread_state;
+
 typedef struct daemon_state {
 	/*
 	 * The maximal stack size for individual daemon threads. This is
@@ -95,9 +97,17 @@ typedef struct daemon_state {
 	int socket_fd;
 
 	log_state *log;
+	struct thread_state *threads;
 	void *private; /* the global daemon state */
 } daemon_state;
 
+typedef struct thread_state {
+	daemon_state s;
+	client_handle client;
+	struct thread_state *next;
+	volatile int active;
+} thread_state;
+
 /*
  * Start serving the requests. This does all the daemonisation, socket setup
  * work and so on. This function takes over the process, and upon failure, it


