From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:44 +0000 (UTC)
Subject: master - cleanup: lvdisplay indent
Message-ID: <20140331100644.C979060AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a33d4355a1e9a08012f348203c0bf673d778c18e
Commit:        a33d4355a1e9a08012f348203c0bf673d778c18e
Parent:        84beba5d7f13c235e14938b3ecfbcb16f938364a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 10:03:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:05:34 2014 +0200

cleanup: lvdisplay indent

---
 tools/lvdisplay.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 246e43b..1f40f09 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -40,12 +40,15 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		return lvs(cmd, argc, argv);
-	} else if (arg_count(cmd, aligned_ARG) ||
-		   arg_count(cmd, noheadings_ARG) ||
-		   arg_count(cmd, options_ARG) ||
-		   arg_count(cmd, separator_ARG) ||
-		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
-		log_error("Incompatible options selected");
+	}
+
+	if (arg_count(cmd, aligned_ARG) ||
+	    arg_count(cmd, noheadings_ARG) ||
+	    arg_count(cmd, options_ARG) ||
+	    arg_count(cmd, separator_ARG) ||
+	    arg_count(cmd, sort_ARG) ||
+	    arg_count(cmd, unbuffered_ARG)) {
+		log_error("Incompatible options selected.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -54,6 +57,5 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, 0, NULL,
-			       &_lvdisplay_single);
+	return process_each_lv(cmd, argc, argv, 0, NULL, &_lvdisplay_single);
 }


