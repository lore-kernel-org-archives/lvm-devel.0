From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Jun 2015 21:56:33 +0000 (UTC)
Subject: master - libdaemon: allow main processing function to be specified
Message-ID: <20150623215633.3837F61054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5ba60827ea720679c70f51b6ee7e999750e44e3
Commit:        c5ba60827ea720679c70f51b6ee7e999750e44e3
Parent:        ba2b701f2cc98eb8e4049866f3d1cc77b61b4abd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 2 14:08:58 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 16:55:45 2015 -0500

libdaemon: allow main processing function to be specified

---
 libdaemon/server/daemon-server.c |    8 +++++++-
 libdaemon/server/daemon-server.h |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index bedd3b2..ef0b964 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -604,6 +604,12 @@ void daemon_start(daemon_state s)
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
+	if (s.daemon_main) {
+		if (!s.daemon_main(&s))
+			failed = 1;
+		goto out;
+	}
+
 	if (s.daemon_init)
 		if (!s.daemon_init(&s))
 			failed = 1;
@@ -635,7 +641,7 @@ void daemon_start(daemon_state s)
 
 	INFO(&s, "%s waiting for client threads to finish", s.name);
 	reap(s, 1);
-
+out:
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
 	if (!_systemd_activation && s.socket_fd >= 0)
 		if (unlink(s.socket_path))
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index 820e5e0..b235edc 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -107,6 +107,7 @@ typedef struct daemon_state {
 	handle_request handler;
 	int (*daemon_init)(struct daemon_state *st);
 	int (*daemon_fini)(struct daemon_state *st);
+	int (*daemon_main)(struct daemon_state *st);
 
 	/* Global runtime info maintained by the framework. */
 	int socket_fd;


