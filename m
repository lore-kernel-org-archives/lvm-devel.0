From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jun 2015 11:43:55 +0000 (UTC)
Subject: master - cleanup: avoid printing gcc warning
Message-ID: <20150623114355.29AE960666@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c86d33e68ceb7a5a5e6754f4551545d915e403d
Commit:        9c86d33e68ceb7a5a5e6754f4551545d915e403d
Parent:        50d70eff352fd651a68b8edbd9a7fcbe30300726
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 11:03:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 23 11:06:02 2015 +0200

cleanup: avoid printing gcc warning

Casting to (void) with gcc doesn't remove unused_result warning.
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=25509
---
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 test/lib/not.c                                     |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 92c08d3..cd71b9c 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -64,7 +64,7 @@ static void kmsg(int log_level, const char *format, ...)
 		return;
 
 	/* The n+4: +3 for "<n>" prefix and +1 for '\0' suffix */
-	(void) write(kmsg_fd, message, n + 4);
+	if (write(kmsg_fd, message, n + 4)) { /* Ignore result code */; }
 }
 
 static void lvm_get_use_lvmetad_and_lvmpolld(int *use_lvmetad, int *use_lvmpolld)
diff --git a/test/lib/not.c b/test/lib/not.c
index 5d28599..93c115a 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -33,9 +33,13 @@ static int _finished(const char *cmd, int status, int pid) {
 			if (WIFEXITED(ret) && WEXITSTATUS(ret) == 0) {
 				printf("## timing off\n<======== Debug log ========>\n"); /* timing off */
 				fflush(stdout);
-				(void) system("sed -e 's,^,## DEBUG: ,' debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null");
+				if (system("sed -e 's,^,## DEBUG: ,' debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null")) {
+				    /* Ignore result code */;
+				}
 				printf("## timing on\n"); /* timing on */
-				(void) system("rm -f debug.log*${LVM_LOG_FILE_EPOCH}*");
+				if (system("rm -f debug.log*${LVM_LOG_FILE_EPOCH}*")) {
+				    /* Ignore result code */;
+				}
 				fflush(stdout);
 			}
 		}


