From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Apr 2021 17:12:01 +0000 (GMT)
Subject: main - man/help: move implied annotation
Message-ID: <20210421171201.1BEF83892015@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66dd481f46099dd118136dacfad0e815e781605a
Commit:        66dd481f46099dd118136dacfad0e815e781605a
Parent:        d651b340e68d97ada25e558eb50aa40062bba936
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 21 12:05:10 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 21 12:05:10 2021 -0500

man/help: move implied annotation

from
[ --type foo (implied) ]

to
[ --type foo] (implied)
---
 tools/command.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 99661a517..6431e2a50 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1979,9 +1979,9 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		if (cmd->autotype) {
 			printf("\n\t");
 			if (!cmd->autotype2)
-				printf("[ --type %s (implied) ]", cmd->autotype);
+				printf("[ --type %s ] (implied)", cmd->autotype);
 			else
-				printf("[ --type %s|%s (implied) ]", cmd->autotype, cmd->autotype2);
+				printf("[ --type %s|%s ] (implied)", cmd->autotype, cmd->autotype2);
 		}
 
 		if (include_extents) {
@@ -2762,9 +2762,9 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 		if (cmd->autotype) {
 			if (!cmd->autotype2)
-				printf("[ \\fB--type %s\\fP (implied) ]\n", cmd->autotype);
+				printf("[ \\fB--type %s\\fP ] (implied)\n", cmd->autotype);
 			else
-				printf("[ \\fB--type %s\\fP|\\fB%s\\fP (implied) ]\n", cmd->autotype, cmd->autotype2);
+				printf("[ \\fB--type %s\\fP|\\fB%s\\fP ] (implied)\n", cmd->autotype, cmd->autotype2);
 			printf(".br\n");
 			sep = 1;
 		}


