From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 21:54:12 +0000 (UTC)
Subject: master - help/man: remove commas from list of options
Message-ID: <20170215215412.CE9BA60D22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22bee4fbdbf3cf52ac6a390b3c1ae983b5350760
Commit:        22bee4fbdbf3cf52ac6a390b3c1ae983b5350760
Parent:        81c0ed9fc6d598ef221e2089e1fd125990a7a626
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 14:00:09 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 15:51:46 2017 -0600

help/man: remove commas from list of options

Using commas between options does not seem to
be done anywhere else, so remove them.
---
 tools/command.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index ac72c49..9f2256b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1624,7 +1624,7 @@ void print_usage(struct command *cmd)
 			if (first)
 				printf("\n\t[");
 			else
-				printf(",\n\t ");
+				printf("\n\t ");
 			first = 0;
 
 			printf(" %s", opt_names[opt_enum].long_opt);
@@ -1637,7 +1637,7 @@ void print_usage(struct command *cmd)
 		if (first)
 			printf("\n\t[");
 		else
-			printf(",\n\t ");
+			printf("\n\t ");
 		printf(" COMMON_OPTIONS ]");
 	}
 
@@ -1687,7 +1687,7 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 		if (first)
 			printf("\n\t[");
 		else
-			printf(",\n\t ");
+			printf("\n\t ");
 		first = 0;
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
@@ -1712,7 +1712,7 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 		if (first)
 			printf("\n\t[");
 		else
-			printf(",\n\t ");
+			printf("\n\t ");
 		first = 0;
 
 		printf(" %s", opt_names[opt_enum].long_opt);
@@ -2081,7 +2081,6 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",");
 				printf("\n.br\n");
 				printf(" ");
 			}
@@ -2112,7 +2111,6 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",");
 				printf("\n.br\n");
 				printf(" ");
 			}
@@ -2130,7 +2128,6 @@ void print_man_usage(char *lvmname, struct command *cmd)
 		}
 
 		if (sep) {
-			printf(",");
 			printf("\n.br\n");
 			printf(" ");
 			/* space alignment without short opt */
@@ -2209,7 +2206,6 @@ void print_man_usage_common(struct command *cmd)
 			continue;
 
 		if (sep) {
-			printf(",");
 			printf("\n.br\n");
 			printf(" ");
 		}
@@ -2246,7 +2242,6 @@ void print_man_usage_common(struct command *cmd)
 			continue;
 
 		if (sep) {
-			printf(",");
 			printf("\n.br\n");
 			printf(" ");
 		}


