From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 31 Jul 2015 08:25:54 +0000 (UTC)
Subject: master - toolcontext: use refresh_filters in refresh_toolcontext
Message-ID: <20150731082554.D46E760F81@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f54198eed62f915df6fdb7c09a186160b5bb3954
Commit:        f54198eed62f915df6fdb7c09a186160b5bb3954
Parent:        0dae377fbf1e0b3e1484984602cbaf73487efa47
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 31 10:20:33 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 31 10:25:36 2015 +0200

toolcontext: use refresh_filters in refresh_toolcontext

Use refresh_filters instead of destroy_filters and init_filters
in refresh_toolcontext fn which deals with cmd->initialized.filters
correctly on refresh.
---
 lib/commands/toolcontext.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c087820..f4c0c95 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2011,7 +2011,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
-	_destroy_filters(cmd);
 
 	if (!dev_cache_exit())
 		stack;
@@ -2109,7 +2108,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (cmd->initialized.connections && !init_connections(cmd))
 		return_0;
 
-	if (cmd->initialized.filters && !init_filters(cmd, 0))
+	if (!refresh_filters(cmd))
 		return_0;
 
 	reset_lvm_errno(1);


