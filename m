From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:27 +0000 (UTC)
Subject: master - cleanup: move string in the use-place
Message-ID: <20130615221627.AB28C60D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=450ac7be4297012d57880e39261eda726cb75eba
Commit:        450ac7be4297012d57880e39261eda726cb75eba
Parent:        17a3ddf89e4148b4fdfe32c2da22beff7b1ca465
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 21:48:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:33 2013 +0200

cleanup: move string in the use-place

---
 tools/pvremove.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index cbbf6e2..2c8f5c6 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -15,9 +15,6 @@
 
 #include "tools.h"
 
-const char _really_wipe[] =
-    "Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ";
-
 /*
  * Decide whether it is "safe" to wipe the labels on this device.
  * 0 indicates we may not.
@@ -74,7 +71,9 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
+	    yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" "
+			  "of volume group \"%s\" [y/n]? ",
+			  name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume label not removed", name);
 		goto bad;
 	}


