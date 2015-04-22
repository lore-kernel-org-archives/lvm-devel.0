From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:24 +0000 (UTC)
Subject: master - tests: explicitely ignore result code
Message-ID: <20150422092024.2E1C960F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afdff405423f1d40db17382db4cf4b0b1dbdbfae
Commit:        afdff405423f1d40db17382db4cf4b0b1dbdbfae
Parent:        30e8b284a7d24fa996d9eeb5b71510d49c9840fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 21 15:46:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 09:09:26 2015 +0200

tests: explicitely ignore result code

---
 test/lib/not.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/not.c b/test/lib/not.c
index ce46699..5d28599 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -33,9 +33,9 @@ static int _finished(const char *cmd, int status, int pid) {
 			if (WIFEXITED(ret) && WEXITSTATUS(ret) == 0) {
 				printf("## timing off\n<======== Debug log ========>\n"); /* timing off */
 				fflush(stdout);
-				system("sed -e 's,^,## DEBUG: ,' debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null");
+				(void) system("sed -e 's,^,## DEBUG: ,' debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null");
 				printf("## timing on\n"); /* timing on */
-				system("rm -f debug.log*${LVM_LOG_FILE_EPOCH}*");
+				(void) system("rm -f debug.log*${LVM_LOG_FILE_EPOCH}*");
 				fflush(stdout);
 			}
 		}


