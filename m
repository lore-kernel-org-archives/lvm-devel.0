From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Nov 2012 13:21:28 +0000 (UTC)
Subject: master - udev: do not verify udev operations for --noudevsync
Message-ID: <20121129132128.A66411328@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb8cc7c63f7f5ab9e0d6d2d38f29169346a54087
Commit:        fb8cc7c63f7f5ab9e0d6d2d38f29169346a54087
Parent:        2be940e54910157da05ffe5d828828e4bcd8b25a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 29 13:59:12 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 29 13:59:12 2012 +0100

udev: do not verify udev operations for --noudevsync

If udev synchronization is disabled by means of --noudevsync
option, we should disable just the synchronization and nothing else.
The udev fallback (verifying udev operations and fixing the
nodes/symlinks if found incorrect) is orthogonal and controlled
by a separate activation/verify_udev_operations configuration option.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    4 +---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 98b5f9e..657b3a4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not verify udev operations if --noudevsync command option is used.
   Fix lvm2api and return lvseg discards property as string.
   Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
   Recognise STEC skd devices in filter.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3720d7f..34d324f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -901,10 +901,8 @@ static int _get_settings(struct cmd_context *cmd)
 	} else
 		init_trust_cache(0);
 
-	if (arg_count(cmd, noudevsync_ARG)) {
+	if (arg_count(cmd, noudevsync_ARG))
 		cmd->current_settings.udev_sync = 0;
-		cmd->current_settings.udev_fallback = 1;
-	}
 
 	/* Handle synonyms */
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||


