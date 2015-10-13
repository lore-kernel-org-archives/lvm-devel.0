From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:31 +0000 (UTC)
Subject: master - toolcontext: do not change already set dm_log
Message-ID: <20151013140331.65EC860E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72d700b064fb64f6bb7e20c23dbb2ce8b6d8feb7
Commit:        72d700b064fb64f6bb7e20c23dbb2ce8b6d8feb7
Parent:        86b04ebd193c9db09ee5f03a2de4997aa2ab52c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:38:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:39:37 2015 +0200

toolcontext: do not change already set dm_log

If the dm_log is already set to non-default logger,
avoid to change it.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 348c099..c089228 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Do not change logging in lvm2 library when it's already set.
   Check for enough space in thin-pool in command before creating new thin.
   Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
   Fix vgimportclone with -n to not add number unnecessarily to base VG name.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c8d96ca..c150991 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -362,7 +362,8 @@ static void _init_logging(struct cmd_context *cmd)
 
 	/* Tell device-mapper about our logging */
 #ifdef DEVMAPPER_SUPPORT
-	dm_log_with_errno_init(print_log);
+	if (!dm_log_is_non_default())
+		dm_log_with_errno_init(print_log);
 #endif
 	reset_log_duplicated();
 	reset_lvm_errno(1);


