From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:17 +0000 (UTC)
Subject: dev-mornfall-activate - lvmetad: no use of persistent filter with lvmetad
Message-ID: <20130604192817.AFEDA6125D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f73e992ef3e233608322cb804b283c3ecdaa72b
Commit:        1f73e992ef3e233608322cb804b283c3ecdaa72b
Parent:        e7878da9216945c3209a430d8b01038312d911bd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 01:55:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:49:55 2013 +0200

lvmetad: no use of persistent filter with lvmetad

---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 748c3fb..ba88915 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not use persistent filter with lvmetad.
   Update persistent filter functinality for global filter.
   Override system's global_filter settings for vgimportclone.
   Detect maximum usable size for snapshot for lvresize.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 965ba4a..af1aa63 100644
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


