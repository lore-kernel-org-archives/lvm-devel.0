From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:51 +0000 (GMT)
Subject: main - man-generator: use \(em
Message-ID: <20210419130051.9BEE6396903A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d94e5ba5afad7297852e4826be21ae30d39f9541
Commit:        d94e5ba5afad7297852e4826be21ae30d39f9541
Parent:        efd0939583484b85ddb8ed3ebb7cda0db51cf473
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 17 00:21:04 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:08 2021 +0200

man-generator: use \(em

Use \(em in command title description and command multidefs.
---
 tools/command.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 556f22e95..cb261531c 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3538,7 +3538,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
 			printf(".SH NAME\n");
 			if (cname && cname->desc)
-				printf("%s - %s\n", lvmname, cname->desc);
+				printf("%s \\(em %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);
 
@@ -3600,7 +3600,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 			_print_man_all_positions_desc(cname);
 		} else {
 			if (cname->variants > 2)
-				printf("-\n");
+				printf("\\(em\n");
 		}
 
 		printf("\n");
@@ -3647,8 +3647,8 @@ static void _print_man_secondary(char *name)
 
 		_print_man_usage(lvmname, cmd);
 
-		printf("-\n");
-		printf("\n");
+		printf("\\(em\n");
+		printf(".P\n");
 	}
 }
 


