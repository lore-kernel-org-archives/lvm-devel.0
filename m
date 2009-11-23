From: Milan Broz <mbroz@redhat.com>
Date: Mon, 23 Nov 2009 20:03:20 +0100
Subject: [PATCH] Refresh device filters before full device rescan in lvmcache.
Message-ID: <1259003000-18591-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The sysfs filter initialise hash of available devices using
scan of /sys/block. We need to refresh even this hash
when performing full scan otherwise the newly appeared
device could be rejected, because there is no entry
in sysfs filter.

This easily could happen when attaching new device
to cluster node. (Only force refresh of context
in clvmd -R works here now).

Unfortunately consequences of this are much worse,
missing device part on that node is replaced with missing segment
(even when no partial arg is selected) and this directly
lead to data corruption.

See https://bugzilla.redhat.com/show_bug.cgi?id=538515

Simply fix it by refreshing device filters in lvmcache
before performing the full device scan.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c       |    5 +++++
 lib/commands/toolcontext.c |   10 ++++++++++
 lib/commands/toolcontext.h |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index dc391c8..54b3c3b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -510,6 +510,11 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 		goto out;
 	}
 
+	if (full_scan && !refresh_filters(cmd)) {
+		log_error("refresh filters failed");
+		goto out;
+	}
+
 	if (!(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
 		log_error("dev_iter creation failed");
 		goto out;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 83485d4..721c2cf 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1223,6 +1223,16 @@ skip_dlclose:
 	}
 }
 
+int refresh_filters(struct cmd_context *cmd)
+{
+	if (cmd->filter) {
+		cmd->filter->destroy(cmd->filter);
+		cmd->filter = NULL;
+	}
+
+	return _init_filters(cmd, 0);
+}
+
 int refresh_toolcontext(struct cmd_context *cmd)
 {
 	log_verbose("Reloading config files");
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index aa3de14..2ffc86d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -105,6 +105,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
+int refresh_filters(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 
-- 
1.6.5.3


