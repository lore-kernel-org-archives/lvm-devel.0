From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Mar 2014 14:23:28 +0000 (UTC)
Subject: master - tests: reinstantiate support for klogctl
Message-ID: <20140304142328.AA9D060E28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30810de1b07a145de8a7629bebcfd0d2e48622a5
Commit:        30810de1b07a145de8a7629bebcfd0d2e48622a5
Parent:        cb77bdc253e695c7e98b0095cb49a6e4f262e384
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 15:10:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 4 15:18:19 2014 +0100

tests: reinstantiate support for klogctl

Add a bit more complexity here - Switch to use /dev/kmsg
which has been introduced in 3.5 kernels and could run without
lossing lines from /proc/kmsg.

On older systems user may set env var LVM_TEST_CAN_CLOBBER_DMESG=1
to get kernel messages via klogctl() call (which deletes dmesg buffer)
otherwise no logging of kernel messages is provided.
---
 test/Makefile.in   |    1 +
 test/lib/harness.c |   34 ++++++++++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5c9f5d5..bf1913a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -66,6 +66,7 @@ help:
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
+	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg."
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
 	@echo "  LVM_TEST_DIR		Where to create test files [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
diff --git a/test/lib/harness.c b/test/lib/harness.c
index a9fff9f..8b2c3b6 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -13,11 +13,13 @@
  */
 
 #define _GNU_SOURCE
+#include <errno.h>
 #include <fcntl.h>
 #include <limits.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <sys/klog.h>
 #include <sys/resource.h> /* rusage */
 #include <sys/select.h>
 #include <sys/socket.h>
@@ -279,6 +281,22 @@ static int drain_fds(int fd1, int fd2, long timeout)
 	return -1;
 }
 
+#define SYSLOG_ACTION_READ_CLEAR     4
+#define SYSLOG_ACTION_CLEAR          5
+
+static void clear_dmesg(void)
+{
+	klogctl(SYSLOG_ACTION_CLEAR, 0, 0);
+}
+
+static void drain_dmesg(void)
+{
+	char buf[1024 * 1024 + 1];
+	size_t sz = klogctl(SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1);
+	buf[sz] = 0;
+	_append_buf(buf, sz);
+}
+
 static const char *duration(time_t start, const struct rusage *usage)
 {
 	static char buf[100];
@@ -398,6 +416,7 @@ static void run(int i, char *f) {
 		struct stat statbuf;
 		int runaway = 0;
 		int no_write = 0;
+		int clobber_dmesg = 0;
 		int collect_debug = 0;
 		int fd_debuglog = -1;
 		int fd_kmsg;
@@ -415,10 +434,13 @@ static void run(int i, char *f) {
 			perror("fopen");
 
 		/* Mix-in kernel log message */
-		if ((fd_kmsg = open("/proc/kmsg", O_RDONLY | O_NONBLOCK)) < 0)
-			perror("open kmsg");
-		else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)
-			perror("lseek kmsg");
+		if ((fd_kmsg = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0) {
+			if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
+				perror("open /dev/kmsg");
+			else if ((clobber_dmesg = strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0")))
+				clear_dmesg();
+		} else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)
+			perror("lseek /dev/kmsg");
 
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
@@ -458,6 +480,8 @@ static void run(int i, char *f) {
 				continue;
 			} else if (ret == (fds[0] + 1))
 				no_write = 0;
+			if (clobber_dmesg)
+				drain_dmesg();
 		}
 		if (w != pid) {
 			perror("waitpid");
@@ -490,6 +514,8 @@ static void run(int i, char *f) {
 
 		if (fd_kmsg >= 0)
 			close(fd_kmsg);
+		else if (clobber_dmesg)
+			drain_dmesg();
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)


