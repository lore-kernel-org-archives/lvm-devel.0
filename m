From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:10 +0000 (UTC)
Subject: master - libdaemon: fprintf(stderr...) -> ERROR()
Message-ID: <20150515183710.3BE88610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d594c409c33884a00be578543589d8207338413
Commit:        8d594c409c33884a00be578543589d8207338413
Parent:        f653b123cf41751ebabfc910061c07e6e3c47149
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 15:50:16 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:31:42 2015 +0200

libdaemon: fprintf(stderr...) -> ERROR()

log data structures are ready. so why not pass
error messages through ERROR()
---
 libdaemon/server/daemon-server.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 6e497b8..bedd3b2 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -598,7 +598,7 @@ void daemon_start(daemon_state s)
 
 	/* Set Close-on-exec */
 	if (!failed && fcntl(s.socket_fd, F_SETFD, 1))
-		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", s.socket_fd, strerror(errno));
+		ERROR(&s, "setting CLOEXEC on socket fd %d failed: %s\n", s.socket_fd, strerror(errno));
 
 	/* Signal parent, letting them know we are ready to go. */
 	if (!s.foreground)


