From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Mar 2017 17:29:43 -0400
Subject: master - man: remove more unnecessary line breaks
Message-ID: <201703142129.v2ELThKA031437@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=531d7c97e7e48a3874448794e724c814ad662114
Commit:        531d7c97e7e48a3874448794e724c814ad662114
Parent:        23d59c6fc1983b84b386efc0558df001d514d141
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 14 16:28:20 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 14 16:28:20 2017 -0500

man: remove more unnecessary line breaks

in case they cause extra blank lines in some output formats.
---
 tools/command.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b1622cc..0abc309 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3301,13 +3301,10 @@ void print_man(char *name, char *des_file, int secondary)
 				printf(".P\n");
 				print_man_all_options_list(cname);
 				printf("\n");
-				printf(".P\n");
-				printf("\n");
 			}
 
 			if (des_file) {
 				include_description_file(lvmname, des_file);
-				printf(".P\n");
 			}
 
 			printf(".SH USAGE\n");
@@ -3330,11 +3327,8 @@ void print_man(char *name, char *des_file, int secondary)
 			printf(".SH VARIABLES\n");
 			print_man_all_positions_desc(cname);
 		} else {
-			if (cname->variants > 2) {
+			if (cname->variants > 2)
 				printf("--\n");
-				printf("\n");
-				printf(".br\n");
-			}
 		}
 
 		printf("\n");
@@ -3383,9 +3377,6 @@ void print_man_secondary(char *name)
 
 		printf("--\n");
 		printf("\n");
-		printf(".br\n");
-
-		printf("\n");
 	}
 }
 


