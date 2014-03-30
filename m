From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:04 +0000 (UTC)
Subject: master - cleanup: pvdisplay indent
Message-ID: <20140330214604.53023602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc82dc7b23902c900ac59c35566bd63d65902155
Commit:        cc82dc7b23902c900ac59c35566bd63d65902155
Parent:        d7b63340793b32e24f9e695c29d97014339fb3ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 23:10:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:44:59 2014 +0200

cleanup: pvdisplay indent

Reindent else path, since other branch already exits with return.
---
 tools/pvdisplay.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index b85635e..3de7969 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -98,12 +98,15 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		return pvs(cmd, argc, argv);
-	} else if (arg_count(cmd, aligned_ARG) ||
-		   arg_count(cmd, all_ARG) ||
-		   arg_count(cmd, noheadings_ARG) ||
-		   arg_count(cmd, options_ARG) ||
-		   arg_count(cmd, separator_ARG) ||
-		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
+	}
+
+	if (arg_count(cmd, aligned_ARG) ||
+	    arg_count(cmd, all_ARG) ||
+	    arg_count(cmd, noheadings_ARG) ||
+	    arg_count(cmd, options_ARG) ||
+	    arg_count(cmd, separator_ARG) ||
+	    arg_count(cmd, sort_ARG) ||
+	    arg_count(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}


