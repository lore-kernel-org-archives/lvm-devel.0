From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:07 -0500
Subject: master - mangenerator: check strdup was successfull
Message-ID: <201812212047.wBLKl7hC021472@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2c017fdace76f0c03f43e3e435ae8a72d6bb15f
Commit:        e2c017fdace76f0c03f43e3e435ae8a72d6bb15f
Parent:        2724a09e586acb38a7fd9ce68223213a32aa37fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 21:08:31 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

mangenerator: check strdup was successfull

Check for strdup != NULL
and drop unneeded zeroing when buffer is overwritten.
---
 tools/command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index c994c39..6931e44 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1460,11 +1460,10 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 
 		if (_is_desc_line(line_argv[0]) && !skip && cmd) {
 			char *desc = dm_pool_strdup(cmdtool->libmem, line_orig);
-			if (cmd->desc) {
+			if (cmd->desc && desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
 				char *newdesc = dm_pool_alloc(cmdtool->libmem, newlen);
 				if (newdesc) {
-					memset(newdesc, 0, newlen);
 					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
 					cmd->desc = newdesc;
 				} else {


