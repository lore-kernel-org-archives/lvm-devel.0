From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  3 Aug 2015 14:20:03 +0000 (UTC)
Subject: master - toolcontext: do not set cmd->initialized_connections = 0 on destroy_toolcontext
Message-ID: <20150803142003.6924E60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3997469b56eb54f78fc84a8d9fde285ffd53c56
Commit:        b3997469b56eb54f78fc84a8d9fde285ffd53c56
Parent:        519c309952245a0d6221a3297399a310acdb8144
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 3 16:17:09 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 3 16:17:17 2015 +0200

toolcontext: do not set cmd->initialized_connections = 0 on destroy_toolcontext

The whole cmd context is freed completely in destroy_toolcontext, so do
not write to any of dead cmd variables.
---
 lib/commands/toolcontext.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f4c0c95..11affee 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2179,7 +2179,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	lvmetad_release_token();
 	lvmetad_disconnect();
 	lvmpolld_disconnect();
-	cmd->initialized.connections = 0;
 
 	release_log_memory();
 	activation_exit();


