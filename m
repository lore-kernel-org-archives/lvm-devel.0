From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 23:56:05 +0000 (UTC)
Subject: dev-mornfall-nix - lvmetad: Never try to use a persistent filter when using lvmetad.
Message-ID: <20130526235605.905CF61414@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c290749686f3508a2749d4d0cf88e0cc3db174a9
Commit:        c290749686f3508a2749d4d0cf88e0cc3db174a9
Parent:        f2936d9837dcf21a6452f624f396972e345d248e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 01:55:14 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 01:55:14 2013 +0200

lvmetad: Never try to use a persistent filter when using lvmetad.

---
 lib/commands/toolcontext.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ec1ea15..3b0d96e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -913,9 +913,11 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	/*
 	 * Only load persistent filter device cache on startup if it is newer
-	 * than the config file and this is not a long-lived process.
+	 * than the config file and this is not a long-lived process. Also avoid
+	 * it when lvmetad is enabled.
 	 */
-	if (load_persistent_cache && !cmd->is_long_lived &&
+	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG) &&
+	    load_persistent_cache && !cmd->is_long_lived &&
 	    !stat(dev_cache, &st) &&
 	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
 	    !persistent_filter_load(f4, NULL))


