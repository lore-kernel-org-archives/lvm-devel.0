From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:50 +0000 (GMT)
Subject: main - cov: daemonize avoid leak of FD on error path
Message-ID: <20210423210550.84F4A394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d388b36da236e66dd42e59d7b5c9d596d6de1961
Commit:        d388b36da236e66dd42e59d7b5c9d596d6de1961
Parent:        d95b26fae0bdab7d306f0dff1d9328a697e041f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:05:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: daemonize avoid leak of FD on error path

Use our common patter for reopening FDs to /dev/null
that avoids leaking FD on error path.
---
 libdm/dm-tools/dmfilemapd.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index e15f0015f..2a86810ed 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -653,18 +653,21 @@ static int _daemonise(struct filemap_monitor *fm)
 	}
 
 	if (!_verbose) {
-		if (close(STDIN_FILENO))
-			_early_log("Error closing stdin");
-		if (close(STDOUT_FILENO))
-			_early_log("Error closing stdout");
-		if (close(STDERR_FILENO))
-			_early_log("Error closing stderr");
-		if ((open("/dev/null", O_RDONLY) < 0) ||
-	            (open("/dev/null", O_WRONLY) < 0) ||
-		    (open("/dev/null", O_WRONLY) < 0)) {
-			_early_log("Error opening stdio streams.");
+		if ((fd = open("/dev/null", O_RDWR)) == -1) {
+			_early_log("Error opening /dev/null.");
 			return 0;
 		}
+
+		if ((dup2(fd, STDIN_FILENO) == -1) ||
+		    (dup2(fd, STDOUT_FILENO) == -1) ||
+		    (dup2(fd, STDERR_FILENO) == -1)) {
+			if (fd > STDERR_FILENO)
+				(void) close(fd);
+			_early_log("Error redirecting stdin/out/err to null.");
+			return 0;
+		}
+		if (fd > STDERR_FILENO)
+			(void) close(fd);
 	}
 	/* TODO: Use libdaemon/server/daemon-server.c _daemonise() */
 	for (fd = (int) sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {


