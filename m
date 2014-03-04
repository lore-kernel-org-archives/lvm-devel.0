From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Mar 2014 16:56:14 +0000 (UTC)
Subject: master - tests: testing usable of /dev/kmsg
Message-ID: <20140304165614.B2C7761028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08aedff1fc86d731f19993c259aaeee19cad7b8c
Commit:        08aedff1fc86d731f19993c259aaeee19cad7b8c
Parent:        9a99cb8c7947e19291794aa80d5bcdc73fa6245f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 17:50:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 4 17:54:33 2014 +0100

tests: testing usable of /dev/kmsg

It's not so easy to recongnize unusable /dev/kmsg
Reorder the code in a way if the first regular read of /dev/kmsg
fail, fallback to klogctl interface.

Call drain_dmesg also for the case there is no user log output.
---
 test/lib/harness.c |   49 +++++++++++++++++++++----------------------------
 1 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 4e9c54f..7ee45c8 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -260,24 +260,6 @@ static int drain(int fd)
 
 static int drain_fds(int fd1, int fd2, long timeout)
 {
-	int ret;
-	fd_set set;
-	struct timeval selectwait = { .tv_usec = timeout };
-
-	FD_ZERO(&set);
-	FD_SET(fd1, &set);
-	if (fd2 >= 0)
-		FD_SET(fd2, &set);
-
-	if ((ret = select(fd2 > fd1 ? fd2 + 1 : fd1 + 1, &set, NULL, NULL, &selectwait)) <= 0)
-		return ret;
-
-	if (FD_ISSET(fd1, &set) && drain(fd1) > 0)
-		return fd1 + 1;
-
-	if (fd2 >= 0 && FD_ISSET(fd2, &set) && drain(fd2) > 0)
-		return fd2 + 1;
-
 	return -1;
 }
 
@@ -422,6 +404,7 @@ static void run(int i, char *f) {
 		int collect_debug = 0;
 		int fd_debuglog = -1;
 		int fd_kmsg;
+		fd_set set;
 		int ret;
 
 		//close(fds[1]);
@@ -439,11 +422,6 @@ static void run(int i, char *f) {
 		if ((fd_kmsg = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0) {
 			if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
 				perror("open /dev/kmsg");
-		} else if (read(fd_kmsg, NULL, 0) == -1) {
-			/* There is /dev/kmsg, but unreadable -> ignore it (RHEL6?) */
-			/* Expected error, stay quiet so log looks nice, perror("read /dev/kmsg"); */
-			close(fd_kmsg);
-			fd_kmsg = -1;
 		} else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)
 			perror("lseek /dev/kmsg");
 
@@ -452,6 +430,8 @@ static void run(int i, char *f) {
 			clear_dmesg();
 
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
+			struct timeval selectwait = { .tv_usec = 500000 }; /* 0.5s */
+
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
 			{
@@ -475,7 +455,15 @@ static void run(int i, char *f) {
 				break;
 			}
 
-			if ((ret = drain_fds(fds[0], fd_kmsg, 500000)) <= 0) {
+			if (clobber_dmesg)
+				drain_dmesg();
+
+			FD_ZERO(&set);
+			FD_SET(fds[0], &set);
+			if (fd_kmsg >= 0)
+				FD_SET(fd_kmsg, &set);
+
+			if ((ret = select(fd_kmsg > fds[0] ? fd_kmsg + 1 : fds[0] + 1, &set, NULL, NULL, &selectwait)) <= 0) {
 				/* Still checking debug log size if it's not growing too much */
 				if (!unlimited && testdirdebug[0] &&
 				    (stat(testdirdebug, &statbuf) == 0) &&
@@ -484,13 +472,18 @@ static void run(int i, char *f) {
 					       statbuf.st_size);
 					goto timeout;
 				}
-
 				no_write++;
 				continue;
-			} else if (ret == (fds[0] + 1))
+			}
+
+			if (FD_ISSET(fds[0], &set) && drain(fds[0]) > 0)
 				no_write = 0;
-			if (clobber_dmesg)
-				drain_dmesg();
+			else if (fd_kmsg >= 0 && FD_ISSET(fd_kmsg, &set) && (drain(fd_kmsg) < 0)) {
+				close(fd_kmsg);
+				fd_kmsg = -1; /* Likely /dev/kmsg is not readable */
+				if ((clobber_dmesg = strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0")))
+					clear_dmesg();
+			}
 		}
 		if (w != pid) {
 			perror("waitpid");


