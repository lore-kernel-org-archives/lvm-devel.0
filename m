From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:05 +0000 (GMT)
Subject: main - cov: use different variable name
Message-ID: <20210920133005.58F873858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=825e49a2447810a806905723bc91072eb7b8b423
Commit:        825e49a2447810a806905723bc91072eb7b8b423
Parent:        376e7072323bc394341c7b9a43a7ca51c2b9e400
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:25:58 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: use different variable name

Better for Coverity to see no change for possibly opened handle.
---
 libdaemon/server/daemon-server.c | 12 ++++++------
 libdm/dm-tools/dmfilemapd.c      |  8 ++++----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 1e900261c..aeb1870a3 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -326,7 +326,7 @@ static void _remove_lockfile(const char *file)
 static void _daemonise(daemon_state s)
 {
 	int child_status;
-	int fd;
+	int fd, ffd;
 	pid_t pid;
 	struct rlimit rlim;
 	struct timeval tval;
@@ -394,17 +394,17 @@ static void _daemonise(daemon_state s)
 
 	/* Switch to sysconf(_SC_OPEN_MAX) ?? */
 	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0)
-		fd = 256; /* just have to guess */
+		ffd = 256; /* just have to guess */
 	else
-		fd = rlim.rlim_cur;
+		ffd = rlim.rlim_cur;
 
-	for (--fd; fd > STDERR_FILENO; fd--) {
+	for (--ffd; ffd > STDERR_FILENO; ffd--) {
 #ifdef __linux__
 		/* Do not close fds preloaded by systemd! */
-		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
+		if (_systemd_activation && ffd == SD_FD_SOCKET_SERVER)
 			continue;
 #endif
-		(void) close(fd);
+		(void) close(ffd);
 	}
 
 	setsid();
diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index 2a86810ed..3799efd83 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -629,7 +629,7 @@ check_unlinked:
 static int _daemonise(struct filemap_monitor *fm)
 {
 	pid_t pid = 0;
-	int fd;
+	int fd, ffd;
 
 	if (!setsid()) {
 		_early_log("setsid failed.");
@@ -670,10 +670,10 @@ static int _daemonise(struct filemap_monitor *fm)
 			(void) close(fd);
 	}
 	/* TODO: Use libdaemon/server/daemon-server.c _daemonise() */
-	for (fd = (int) sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {
-		if (fd == fm->fd)
+	for (ffd = (int) sysconf(_SC_OPEN_MAX) - 1; ffd > STDERR_FILENO; --ffd) {
+		if (ffd == fm->fd)
 			continue;
-		(void) close(fd);
+		(void) close(ffd);
 	}
 
 	return 1;


