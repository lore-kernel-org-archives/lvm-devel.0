From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:06 +0000 (UTC)
Subject: master - clvmd,lvmetad: check for fcntl result
Message-ID: <20120823124306.08A62A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6f680ee4945f22670d133ba341bb670c1d0a474
Commit:        c6f680ee4945f22670d133ba341bb670c1d0a474
Parent:        5d0e7fb4edbe2c4e999eaa6210b6c9e25bdd5e91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 20 10:49:16 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

clvmd,lvmetad: check for fcntl result

Report any problem of fcntl.
---
 daemons/clvmd/clvmd.c            |    3 ++-
 libdaemon/server/daemon-server.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index f74490a..ac465d9 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2155,7 +2155,8 @@ static int open_local_sock(void)
 	/* Set Close-on-exec & non-blocking */
 	if (fcntl(local_socket, F_SETFD, 1))
 		DEBUGLOG("setting CLOEXEC on local_socket failed: %s\n", strerror(errno));
-	fcntl(local_socket, F_SETFL, fcntl(local_socket, F_GETFL, 0) | O_NONBLOCK);
+	if (fcntl(local_socket, F_SETFL, fcntl(local_socket, F_GETFL, 0) | O_NONBLOCK))
+		DEBUGLOG("setting O_NONBLOCK on local_socket failed: %s\n", strerror(errno));
 
 
 	if (bind(local_socket, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index df75ac7..ef26cbc 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -220,7 +220,8 @@ static int _open_socket(daemon_state s)
 	/* Set Close-on-exec & non-blocking */
 	if (fcntl(fd, F_SETFD, 1))
 		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
-	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
+	if (fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK))
+		fprintf(stderr, "setting O_NONBLOCK on socket fd %d failed: %s\n", fd, strerror(errno));
 
 	fprintf(stderr, "[D] creating %s\n", s.socket_path);
 	if (!dm_strncpy(sockaddr.sun_path, s.socket_path, sizeof(sockaddr.sun_path))) {


