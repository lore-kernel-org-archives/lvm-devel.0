From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:26 +0000 (GMT)
Subject: main - daemon-server: handle reaping threads better
Message-ID: <20210406200726.3B3153858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f17b1c56526abc7b7c8edacfba683b396f95705
Commit:        1f17b1c56526abc7b7c8edacfba683b396f95705
Parent:        fe4f83171d43ed764b2342f2081db8d9e8ce9343
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 1 11:32:47 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

daemon-server: handle reaping threads better

Avoid sleeping in pselect when thread missed reap() handling.
This speedup handling of daemon shutdown sequences.
---
 libdaemon/server/daemon-server.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 7c1b1cf89..1e900261c 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -551,9 +551,14 @@ static void _reap(daemon_state s, int waiting)
 
 	while (ts) {
 		if (waiting || !ts->active) {
-			if (ts->client.thread_id &&
-			    (errno = pthread_join(ts->client.thread_id, &rv)))
-				ERROR(&s, "pthread_join failed: %s", strerror(errno));
+			if (ts->client.thread_id) {
+				if ((errno = pthread_kill(ts->client.thread_id, SIGTERM)) &&
+				    (errno != ESRCH))
+					ERROR(&s, "pthread_kill failed for pid %ld",
+					      (long)ts->client.thread_id);
+				if ((errno = pthread_join(ts->client.thread_id, &rv)))
+					ERROR(&s, "pthread_join failed: %s", strerror(errno));
+			}
 			last->next = ts->next;
 			free(ts);
 		} else
@@ -659,19 +664,13 @@ void daemon_start(daemon_state s)
 	if (sigprocmask(SIG_SETMASK, NULL, &old_set))
 		perror("sigprocmask error");
 
-	while (!failed) {
+	while (!failed && !_shutdown_requested) {
 		_reset_timeout(s);
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
 
 		if (sigprocmask(SIG_SETMASK, &new_set, NULL))
 			perror("sigprocmask error");
-		if (_shutdown_requested && !s.threads->next) {
-			if (sigprocmask(SIG_SETMASK, &old_set, NULL))
-				perror("sigprocmask error");
-			INFO(&s, "%s shutdown requested", s.name);
-			break;
-		}
 		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);
 		if (sigprocmask(SIG_SETMASK, &old_set, NULL))
 			perror("sigprocmask error");
@@ -679,6 +678,7 @@ void daemon_start(daemon_state s)
 		if (ret < 0) {
 			if ((errno != EINTR) && (errno != EAGAIN))
 				perror("select error");
+			_reap(s, 0);
 			continue;
 		}
 
@@ -698,6 +698,9 @@ void daemon_start(daemon_state s)
 		}
 	}
 
+	if (_shutdown_requested)
+		INFO(&s, "%s shutdown requested", s.name);
+
 	INFO(&s, "%s waiting for client threads to finish", s.name);
 	_reap(s, 1);
 out:


