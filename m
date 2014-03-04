From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Mar 2014 15:27:51 +0000 (UTC)
Subject: master - tests: check readability of /dev/kmsg
Message-ID: <20140304152751.9115C61338@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b47bdb4dca6eda577206aa76b83697524111d046
Commit:        b47bdb4dca6eda577206aa76b83697524111d046
Parent:        30810de1b07a145de8a7629bebcfd0d2e48622a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 16:22:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 4 16:27:00 2014 +0100

tests: check readability of /dev/kmsg

Looks like there are systems with /dev/kmsg device,
which is however not readable

Fix check for result value of klogctl and use only positive value.
---
 test/lib/harness.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 8b2c3b6..d02e9de 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -292,9 +292,11 @@ static void clear_dmesg(void)
 static void drain_dmesg(void)
 {
 	char buf[1024 * 1024 + 1];
-	size_t sz = klogctl(SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1);
-	buf[sz] = 0;
-	_append_buf(buf, sz);
+	int sz = klogctl(SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1);
+	if (sz > 0) {
+		buf[sz] = 0;
+		_append_buf(buf, sz);
+	}
 }
 
 static const char *duration(time_t start, const struct rusage *usage)
@@ -437,11 +439,18 @@ static void run(int i, char *f) {
 		if ((fd_kmsg = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0) {
 			if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
 				perror("open /dev/kmsg");
-			else if ((clobber_dmesg = strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0")))
-				clear_dmesg();
+		} else if (read(fd_kmsg, NULL, 0) == -1) {
+			/* There is /dev/kmsg, but unreadable -> ignore it (RHEL6?) */
+			perror("read /dev/kmsg");
+			close(fd_kmsg);
+			fd_kmsg = -1;
 		} else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)
 			perror("lseek /dev/kmsg");
 
+		if ((fd_kmsg < 0) &&
+		    (clobber_dmesg = strcmp(getenv("LVM_TEST_CAN_CLOBBER_DMESG") ? : "0", "0")))
+			clear_dmesg();
+
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */


