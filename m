From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:47 -0400
Subject: stable-2.02 - cov: ensure cname exists before derefering it
Message-ID: <201906251545.x5PFjlBD013765@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff2bf113604882a0f21f118a5bb16076399bb67a
Commit:        ff2bf113604882a0f21f118a5bb16076399bb67a
Parent:        7232458b6c114cc83b471f08abc49fd1673831c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:29:26 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:34:18 2019 +0200

cov: ensure cname exists before derefering it

Just make it clear to analyzers  cname can't be NULL.
TODO: maybe exclude NULL at front of the function...
---
 tools/command.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 377d03f..5237532 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1916,7 +1916,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_cmd()
 			 */
 
-			if ((cname->variants > 1) && cname->common_options[opt_enum])
+			if (cname && (cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
 			printf("\n\t[");
@@ -1956,7 +1956,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_cmd()
 			 */
 
-			if ((cname->variants > 1) && cname->common_options[opt_enum])
+			if (cname && (cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
 			printf("\n\t[");
@@ -3384,7 +3384,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
 			printf(".SH NAME\n");
-			if (cname->desc)
+			if (cname && cname->desc)
 				printf("%s - %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);


