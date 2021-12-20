From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:10 +0000 (GMT)
Subject: main - lvmcmdline: comment reset of configuration settings
Message-ID: <20211220151410.975A13858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a78979b68c4ae822c3f9bcc7ba662c7aa727b40
Commit:        5a78979b68c4ae822c3f9bcc7ba662c7aa727b40
Parent:        39a121ddbcf83314c5a75e23671acbc6600292ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 17 16:41:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

lvmcmdline: comment reset of configuration settings

We used to reset 'settings' to their defaults after command is finished.
This however has a drawback we lose all the logging after this point.

So this patch disables this 'reset' to observe for side-effects.

lvm shell should be getting reset when next command is run -
so this might or might not have some 'hidden' effects.

ATM it looks like nothing really bad should happen - we just should be
able to get more logs - at least from normal commands.
---
 tools/lvmcmdline.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7e3afc241..241c6df18 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3335,8 +3335,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 * ignore everything supplied on the command line of the
 	 * completed command.
 	 */
-	_reset_current_settings_to_default(cmd);
-	_apply_current_settings(cmd);
+	//_reset_current_settings_to_default(cmd);
+	//_apply_current_settings(cmd);
 
 	/*
 	 * free off any memory the command used.


