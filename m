From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:33 -0400
Subject: master - cov: ensure cname exists before derefering it
Message-ID: <201908091058.x79AwXtn031567@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc4a92b13c08f500c1dc0c7af95af599b1c15095
Commit:        cc4a92b13c08f500c1dc0c7af95af599b1c15095
Parent:        46f1d17c743145d3ffa045557a6a792eb99f478a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:29:26 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

cov: ensure cname exists before derefering it

Just make it clear to analyzers  cname can't be NULL.
TODO: maybe exclude NULL at front of the function...
---
 tools/command.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 724040e..2e69eff 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1935,7 +1935,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_cmd()
 			 */
 
-			if ((cname->variants > 1) && cname->common_options[opt_enum])
+			if (cname && (cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
 			printf("\n\t[");
@@ -1975,7 +1975,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_cmd()
 			 */
 
-			if ((cname->variants > 1) && cname->common_options[opt_enum])
+			if (cname && (cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
 			printf("\n\t[");
@@ -3438,7 +3438,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
 			printf(".SH NAME\n");
-			if (cname->desc)
+			if (cname && cname->desc)
 				printf("%s - %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);


