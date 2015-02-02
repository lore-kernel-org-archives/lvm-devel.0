From: okozina <okozina@fedoraproject.org>
Date: Mon,  2 Feb 2015 09:21:14 +0000 (UTC)
Subject: master - libdaemon: set CLOEXEC flag on systemd socket
Message-ID: <20150202092114.69F8760324@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f73526f58cd8e86a19b5cd8a26449ef40c9697ef
Commit:        f73526f58cd8e86a19b5cd8a26449ef40c9697ef
Parent:        9dd81df8b25a51c919679b5f1c4e5fea9269972b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Jan 30 15:15:24 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Feb 2 10:20:35 2015 +0100

libdaemon: set CLOEXEC flag on systemd socket

all sockets opened by a daemon or handed over by systemd
have to have CLOEXEC flag set. Otherwise we get nasty
warnings about leaking descriptors in processes spawned by
daemon.
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3555063..cd4abfe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  set CLOEXEC flag on file descriptors originating in libdaemon
 
 Version 2.02.116 - 30th January 2015
 ====================================
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3dffdbb..5ccf4e9 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -221,9 +221,7 @@ static int _open_socket(daemon_state s)
 		goto error;
 	}
 
-	/* Set Close-on-exec & non-blocking */
-	if (fcntl(fd, F_SETFD, 1))
-		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
+	/* Set non-blocking */
 	if (fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK))
 		fprintf(stderr, "setting O_NONBLOCK on socket fd %d failed: %s\n", fd, strerror(errno));
 
@@ -572,6 +570,10 @@ void daemon_start(daemon_state s)
 			failed = 1;
 	}
 
+	/* Set Close-on-exec */
+	if (fcntl(s.socket_fd, F_SETFD, 1))
+		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", s.socket_fd, strerror(errno));
+
 	/* Signal parent, letting them know we are ready to go. */
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);


