From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 13 May 2015 12:45:56 +0000 (UTC)
Subject: master - libdaemon: Fix socket reuse error paths.
Message-ID: <20150513124556.7511C6034F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02e10f4ccd60f66a00d5406452459317baba7c62
Commit:        02e10f4ccd60f66a00d5406452459317baba7c62
Parent:        cc560b75aa5144ce6859e6d0ecc4cb918af7f4d8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 13 13:42:09 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 13 13:42:09 2015 +0100

libdaemon: Fix socket reuse error paths.

Invert S_ISSOCK validation.
Fail instead of replacing a symlink with a new socket.
After failure, skip calling fcntl with invalid socket_fd.
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e1674e2..e92c01a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Fix some libdaemon socket creation and reuse error paths.
   Daemons (libdaemon) support exit on idle also in non-systemd environment.
   Provide make dist and make rpm targets
   Configure lvm.conf for use_lvmetad and use_lvmpolld.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 5b1aff1..e1a9da9 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -261,12 +261,12 @@ static int _open_socket(daemon_state s)
 		}
 
 		/* Socket already exists. If it's stale, remove it. */
-		if (stat(sockaddr.sun_path, &buf)) {
+		if (lstat(sockaddr.sun_path, &buf)) {
 			perror("stat failed");
 			goto error;
 		}
 
-		if (S_ISSOCK(buf.st_mode)) {
+		if (!S_ISSOCK(buf.st_mode)) {
 			fprintf(stderr, "%s: not a socket\n", sockaddr.sun_path);
 			goto error;
 		}
@@ -595,7 +595,7 @@ void daemon_start(daemon_state s)
 	}
 
 	/* Set Close-on-exec */
-	if (fcntl(s.socket_fd, F_SETFD, 1))
+	if (!failed && fcntl(s.socket_fd, F_SETFD, 1))
 		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", s.socket_fd, strerror(errno));
 
 	/* Signal parent, letting them know we are ready to go. */


