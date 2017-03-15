From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Mar 2017 12:41:50 -0400
Subject: master - help: fix missing newlines
Message-ID: <201703151641.v2FGfocV017142@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c5df43ea31ec848a1d5483541afb75c67e3558f
Commit:        5c5df43ea31ec848a1d5483541afb75c67e3558f
Parent:        60eb74a27ad91112d9a3d0409286e1de2789418f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 15 11:40:59 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 15 11:40:59 2017 -0500

help: fix missing newlines

Recent commits to remove newlines from man output
accidentally removed some newlines from help output.
---
 tools/command.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 514a71c..6335d06 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1869,6 +1869,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (!desc_first && cmd->desc)
 		_print_usage_description(cmd);
 
+	printf("\n");
 	return;
 }
 
@@ -1915,7 +1916,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf("\n");
+	printf("\n\n");
 }
 
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
@@ -1988,7 +1989,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf("\n");
+	printf("\n\n");
 }
 
 void print_usage_notes(struct command_name *cname)


