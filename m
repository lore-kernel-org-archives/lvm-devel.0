From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 12:37:02 -0500
Subject: master - daemons: use DEFAULT_PROC_DIR in dmfilemapd
Message-ID: <201703101737.v2AHb2x4019202@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9341b18ef6cb20245a74fc97aa28dd7283804f3
Commit:        a9341b18ef6cb20245a74fc97aa28dd7283804f3
Parent:        b17eb054cd79d26573bf8a9ad1621dd1026cb11d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 17:25:11 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 17:26:47 2017 +0000

daemons: use DEFAULT_PROC_DIR in dmfilemapd

Include defaults.h and use it to obtain the default procfs mount
point in dmfilemapd.
---
 daemons/dmfilemapd/dmfilemapd.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 67f86d3..6d7c09f 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -18,6 +18,8 @@
 
 #include "dm-logging.h"
 
+#include "defaults.h"
+
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <unistd.h>
@@ -146,7 +148,8 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 	if (pid == getpid())
 		return 0;
 
-	if (dm_snprintf(path_buf, sizeof(path_buf), "/proc/%d/fd", pid) < 0) {
+	if (dm_snprintf(path_buf, sizeof(path_buf),
+			DEFAULT_PROC_DIR "%d/fd", pid) < 0) {
 		log_error("Could not format pid path.");
 		goto bad;
 	}
@@ -170,7 +173,8 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 			continue;
 		if ((len = readlinkat(dirfd(pid_d), pid_dp->d_name, link_buf,
 				      sizeof(link_buf))) < 0) {
-			log_error("readlink failed for /proc/%d/fd/.", pid);
+			log_error("readlink failed for " DEFAULT_PROC_DIR
+				  "/%d/fd/.", pid);
 			goto bad;
 		}
 		link_buf[len] = '\0';
@@ -211,7 +215,7 @@ static int _is_open(const char *path)
 	DIR *proc_d = NULL;
 	pid_t pid;
 
-	proc_d = opendir("/proc");
+	proc_d = opendir(DEFAULT_PROC_DIR);
 	if (!proc_d)
 		return 0;
 	while ((proc_dp = readdir(proc_d)) != NULL) {
@@ -563,13 +567,13 @@ check_unlinked:
 	 * whether it is still reachable in the filesystem, or if it is
 	 * unlinked and anonymous.
 	 */
-	if (dm_snprintf(path_buf, sizeof(path_buf),
-			"/proc/%d/fd/%d", getpid(), fm->fd) < 0) {
+	if (dm_snprintf(path_buf, sizeof(path_buf), DEFAULT_PROC_DIR
+			"/%d/fd/%d", getpid(), fm->fd) < 0) {
 		log_error("Could not format pid path.");
 		return 0;
 	}
 	if ((len = readlink(path_buf, link_buf, sizeof(link_buf))) < 0) {
-		log_error("readlink failed for /proc/%d/fd/%d.",
+		log_error("readlink failed for " DEFAULT_PROC_DIR "/%d/fd/%d.",
 			  getpid(), fm->fd);
 		return 0;
 	}


