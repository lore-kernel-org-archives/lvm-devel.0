From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Nov 2018 15:40:52 -0500
Subject: master - lvmlockd: vgchange locktype with yes option
Message-ID: <201811272040.wARKeq0q029235@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea9b2c2122d76b7fbdb0fb78e854acdf0f80ec87
Commit:        ea9b2c2122d76b7fbdb0fb78e854acdf0f80ec87
Parent:        d8284beb23f7a81b27e5acb0ecb90d76809df736
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 27 14:38:39 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 27 14:40:24 2018 -0600

lvmlockd: vgchange locktype with yes option

for auto response to yes/no prompt.
---
 tools/vgchange.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index e8e302c..0f9241c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1045,7 +1045,8 @@ int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv)
 			return 0;
 		}
 
-		if (yes_no_prompt("Forcibly change VG lock type to none? [y/n]: ") == 'n') {
+		if (!arg_is_set(cmd, yes_ARG) &&
+		     yes_no_prompt("Forcibly change VG lock type to none? [y/n]: ") == 'n') {
 			log_error("VG lock type not changed.");
 			return 0;
 		}


