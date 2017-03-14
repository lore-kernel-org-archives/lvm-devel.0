From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Mar 2017 16:05:27 -0400
Subject: master - man: remove redundant line breaks
Message-ID: <201703142005.v2EK5RXl025261@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23d59c6fc1983b84b386efc0558df001d514d141
Commit:        23d59c6fc1983b84b386efc0558df001d514d141
Parent:        5942fd18dbf961fa1222a76b7f95ddef6c3edf09
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 14 14:58:30 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 14 15:04:58 2017 -0500

man: remove redundant line breaks

unecessary .br and .P
---
 tools/command.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 9f6b078..b1622cc 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3135,9 +3135,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
-	printf(".SH ENVIRONMENT VARIABLES");
-	printf("\n");
-	printf(".br\n");
+	printf(".SH ENVIRONMENT VARIABLES\n");
 	printf("See \\fBlvm\\fP(8) for information about environment variables used by lvm.\n"
 	       "For example, LVM_VG_NAME can generally be substituted for a required VG parameter.\n");
 }
@@ -3244,7 +3242,6 @@ void print_man(char *name, char *des_file, int secondary)
 
 			printf("\n");
 			printf(".SH OPTIONS\n");
-			printf(".br\n");
 			print_man_all_options_desc(cname);
 			printf(".SH VARIABLES\n");
 			printf(".br\n");
@@ -3264,18 +3261,13 @@ void print_man(char *name, char *des_file, int secondary)
 
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
 			printf(".SH NAME\n");
-			printf(".\n");
 			if (cname->desc)
 				printf("%s \\- %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);
-			printf(".P\n");
 
 			printf(".\n");
 			printf(".SH SYNOPSIS\n");
-			printf(".br\n");
-			printf(".P\n");
-			printf(".\n");
 			prev_cmd = cmd;
 
 			if (!(cname = find_command_name(cmd->name)))
@@ -3302,7 +3294,6 @@ void print_man(char *name, char *des_file, int secondary)
 				printf(".br\n");
 			}
 
-			printf(".P\n");
 			printf("\n");
 
 			/* listing them all when there's only 1 or 2 is just repetative */
@@ -3320,9 +3311,6 @@ void print_man(char *name, char *des_file, int secondary)
 			}
 
 			printf(".SH USAGE\n");
-			printf(".br\n");
-			printf(".P\n");
-			printf(".\n");
 		}
 
 		if (cmd->desc) {
@@ -3338,10 +3326,8 @@ void print_man(char *name, char *des_file, int secondary)
 
 			printf("\n");
 			printf(".SH OPTIONS\n");
-			printf(".br\n");
 			print_man_all_options_desc(cname);
 			printf(".SH VARIABLES\n");
-			printf(".br\n");
 			print_man_all_positions_desc(cname);
 		} else {
 			if (cname->variants > 2) {


