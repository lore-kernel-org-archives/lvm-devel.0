From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Jul 2016 13:49:37 +0000 (UTC)
Subject: master - cleanup: local static functions with _
Message-ID: <20160715134937.0EBAB60E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e96d1ad3efea51448f0cdd39e7c84db05d3c6cbf
Commit:        e96d1ad3efea51448f0cdd39e7c84db05d3c6cbf
Parent:        4de7a843ebc5c9ed4c54225a1a062cf40534edaf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 15 13:20:35 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 15 15:49:01 2016 +0200

cleanup: local static functions with _

---
 libdaemon/server/daemon-server.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index e4d7ce2..c3402a0 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -319,7 +319,7 @@ error:
 	goto out;
 }
 
-static void remove_lockfile(const char *file)
+static void _remove_lockfile(const char *file)
 {
 	if (unlink(file))
 		perror("unlink failed");
@@ -418,7 +418,7 @@ end:
 	return res;
 }
 
-static response builtin_handler(daemon_state s, client_handle h, request r)
+static response _builtin_handler(daemon_state s, client_handle h, request r)
 {
 	const char *rq = daemon_request_str(r, "request", "NONE");
 	response res = { .error = EPROTO };
@@ -432,7 +432,7 @@ static response builtin_handler(daemon_state s, client_handle h, request r)
 	return res;
 }
 
-static void *client_thread(void *state)
+static void *_client_thread(void *state)
 {
 	thread_state *ts = state;
 	request req;
@@ -451,7 +451,7 @@ static void *client_thread(void *state)
 		else
 			daemon_log_cft(ts->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 
-		res = builtin_handler(ts->s, ts->client, req);
+		res = _builtin_handler(ts->s, ts->client, req);
 
 		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
 			res = ts->s.handler(ts->s, ts->client, req);
@@ -512,7 +512,7 @@ static int handle_connect(daemon_state s)
 	ts->s = s;
 	ts->client = client;
 
-	if (pthread_create(&ts->client.thread_id, NULL, client_thread, ts)) {
+	if (pthread_create(&ts->client.thread_id, NULL, _client_thread, ts)) {
 		ERROR(&s, "Failed to create client thread.");
 		return 0;
 	}
@@ -520,7 +520,7 @@ static int handle_connect(daemon_state s)
 	return 1;
 }
 
-static void reap(daemon_state s, int waiting)
+static void _reap(daemon_state s, int waiting)
 {
 	thread_state *last = s.threads, *ts = last->next;
 	void *rv;
@@ -637,7 +637,7 @@ void daemon_start(daemon_state s)
 			handle_connect(s);
 		}
 
-		reap(s, 0);
+		_reap(s, 0);
 
 		if (_shutdown_requested && !s.threads->next)
 			break;
@@ -653,7 +653,7 @@ void daemon_start(daemon_state s)
 	}
 
 	INFO(&s, "%s waiting for client threads to finish", s.name);
-	reap(s, 1);
+	_reap(s, 1);
 out:
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
 	if (!_systemd_activation && s.socket_fd >= 0)
@@ -672,7 +672,7 @@ out:
 
 	closelog(); /* FIXME */
 	if (s.pidfile)
-		remove_lockfile(s.pidfile);
+		_remove_lockfile(s.pidfile);
 	if (failed)
 		exit(1);
 }


