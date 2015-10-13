From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:36:31 +0000 (UTC)
Subject: master - Revert "log: no file for external logging"
Message-ID: <20151013143631.A1ECA60EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0cf787a377548394f4588b671c2890ee1a45098b
Commit:        0cf787a377548394f4588b671c2890ee1a45098b
Parent:        acc70de43968961e9a71612cda04642e4fbfd71f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 13 15:31:57 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 13 15:31:57 2015 +0100

Revert "log: no file for external logging"

This reverts commit 1b1c01a27b359f8e91c3c9e08684c435d8fd51c2.

This caused messages to get dropped instead of logged into the log file.

(The log file and log function are independent at the moment.)
---
 WHATS_NEW     |    1 -
 lib/log/log.c |    4 ----
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7507b9c..c089228 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.133 - 
 ======================================
-  Avoid creation of log file when logging function is set.
   Do not change logging in lvm2 library when it's already set.
   Check for enough space in thin-pool in command before creating new thin.
   Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
diff --git a/lib/log/log.c b/lib/log/log.c
index 2f1be72..c44c3d4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -71,10 +71,6 @@ void init_log_file(const char *log_file, int append)
 	int i = 0;
 
 	_log_file_path[0] = '\0';
-
-	if (_lvm2_log_fn)
-		return; /* No log file, when log function is set */
-
 	if ((env = getenv("LVM_LOG_FILE_EPOCH"))) {
 		while (isalpha(env[i]) && i < 32) /* Up to 32 alphas */
 			i++;


