From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:19 +0000 (UTC)
Subject: master - cleanup: check arg_count once
Message-ID: <20140717142919.B45A660DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab72cdbf81ef5a52a63098b1997b3a6765a9edc5
Commit:        ab72cdbf81ef5a52a63098b1997b3a6765a9edc5
Parent:        321592af71686b8963a6bae276533f4f19946578
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 14 17:34:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:18:35 2014 +0200

cleanup: check arg_count once

Do not check quiet_ARG more then necessary.
---
 tools/lvmcmdline.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index be7844b..ccef904 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -935,11 +935,9 @@ static int _get_settings(struct cmd_context *cmd)
 	if (arg_count(cmd, quiet_ARG)) {
 		cmd->current_settings.debug = 0;
 		cmd->current_settings.verbose = 0;
+		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
 
-	if (arg_count(cmd, quiet_ARG) > 1)
-		cmd->current_settings.silent = 1;
-
 	if (arg_count(cmd, test_ARG))
 		cmd->current_settings.test = arg_count(cmd, test_ARG);
 


