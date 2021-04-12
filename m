From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:45 +0000 (GMT)
Subject: main - man-generator: remove ',' between some options
Message-ID: <20210412075545.4925F39FCC74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=441b702362ad6a756551f059d4ca8d62713de6ac
Commit:        441b702362ad6a756551f059d4ca8d62713de6ac
Parent:        d86b5836442a357e6c01ee897b5d530e14494f73
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 14:28:51 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man-generator: remove ',' between some options

It would be complicated to handle ',' alignment after hyphenation
changes ATM, but these commas seems to be there rather unneeded
so remove them and make the man output more clear.
---
 tools/command.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 7e0c2584d..0f31c5138 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2559,10 +2559,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",\n");
-				printf(".ad b\n");
-				printf(".br\n");
-				printf(".ad l\n");
+				printf("\n.br\n");
 				printf(" ");
 			}
 
@@ -2591,10 +2588,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",\n");
-				printf(".ad b\n");
-				printf(".br\n");
-				printf(".ad l\n");
+				printf("\n.br\n");
 				printf(" ");
 			} else
 				printf(".ad l\n");


