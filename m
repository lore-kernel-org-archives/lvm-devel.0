From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 15:11:11 -0500
Subject: master - man: change the synopsis option style
Message-ID: <201703022011.v22KBBOv029786@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3bcec599354df6c2645d5872be0bae293caccb4
Commit:        d3bcec599354df6c2645d5872be0bae293caccb4
Parent:        910918d1c24f5edd07abd638958bc52da1e147c8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 14:08:59 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 14:08:59 2017 -0600

man: change the synopsis option style

Remove the required/optional words because it
should already be evident from the use of [ ].
---
 tools/command.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0187972..28c77e4 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2984,23 +2984,23 @@ void print_man(char *name, char *des_file, int secondary)
 				return;
 
 			if (cname->variant_has_ro && cname->variant_has_rp)
-				printf("\\fB%s\\fP \\fIrequired_option_args\\fP \\fIrequired_position_args\\fP\n", lvmname);
+				printf("\\fB%s\\fP \\fIoption_args\\fP \\fIposition_args\\fP\n", lvmname);
 			else if (cname->variant_has_ro && !cname->variant_has_rp)
-				printf("\\fB%s\\fP \\fIrequired_option_args\\fP\n", lvmname);
+				printf("\\fB%s\\fP \\fIoption_args\\fP\n", lvmname);
 			else if (!cname->variant_has_ro && cname->variant_has_rp)
-				printf("\\fB%s\\fP \\fIrequired_position_args\\fP\n", lvmname);
+				printf("\\fB%s\\fP \\fIposition_args\\fP\n", lvmname);
 			else if (!cname->variant_has_ro && !cname->variant_has_rp)
 				printf("\\fB%s\\fP\n", lvmname);
 
 			printf(".br\n");
 
 			if (cname->variant_has_oo) {
-				printf("    [ \\fIoptional_option_args\\fP ]\n");
+				printf("    [ \\fIoption_args\\fP ]\n");
 				printf(".br\n");
 			}
 
 			if (cname->variant_has_op) {
-				printf("    [ \\fIoptional_position_args\\fP ]\n");
+				printf("    [ \\fIposition_args\\fP ]\n");
 				printf(".br\n");
 			}
 


