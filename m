From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:33 +0000 (UTC)
Subject: master - log: no file for external logging
Message-ID: <20151013140333.788AB60EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b1c01a27b359f8e91c3c9e08684c435d8fd51c2
Commit:        1b1c01a27b359f8e91c3c9e08684c435d8fd51c2
Parent:        72d700b064fb64f6bb7e20c23dbb2ce8b6d8feb7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:44:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:40:44 2015 +0200

log: no file for external logging

When external logging is set do not bother creating log file,
as it's not going to be used.
---
 WHATS_NEW     |    1 +
 lib/log/log.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c089228..7507b9c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Avoid creation of log file when logging function is set.
   Do not change logging in lvm2 library when it's already set.
   Check for enough space in thin-pool in command before creating new thin.
   Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
diff --git a/lib/log/log.c b/lib/log/log.c
index bd11363..7f31361 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -74,6 +74,10 @@ void init_log_file(const char *log_file, int append)
 	int i = 0;
 
 	_log_file_path[0] = '\0';
+
+	if (_lvm2_log_fn)
+		return; /* No log file, when log function is set */
+
 	if ((env = getenv("LVM_LOG_FILE_EPOCH"))) {
 		while (isalpha(env[i]) && i < 32) /* Up to 32 alphas */
 			i++;


