From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:41 +0000 (UTC)
Subject: dev-mornfall-activate - filters: dump filter returns error code
Message-ID: <20130604192841.AD46760F8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f05c5a97c35f4a01b20cb3b31003b53348ce81d9
Commit:        f05c5a97c35f4a01b20cb3b31003b53348ce81d9
Parent:        4a657a13b1c6e4570c15c14fd8acb910b106f5cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 2 23:27:34 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 3 08:42:25 2013 +0200

filters: dump filter returns error code

Add int return value from dump() function.
Report stack for error case.
Update composable filter.
---
 WHATS_NEW                      |    1 +
 lib/cache/lvmcache.c           |    5 +++--
 lib/commands/toolcontext.c     |    5 +++--
 lib/device/dev-cache.h         |    2 +-
 lib/filters/filter-composite.c |   17 +++++++++--------
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd2d8ed..fe42b81 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Report backtrace from dump filter error path.
   Do not use persistent filter with lvmetad.
   Composable persistent filter functionality for global filter.
   Override system's global_filter settings for vgimportclone.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 81b8de1..6f935db 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -708,8 +708,9 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	 * device cache for the benefit of short-lived processes.
 	 */
 	if (full_scan == 2 && cmd->is_long_lived &&
-	    cmd->dump_filter && cmd->filter && cmd->filter->dump)
-		cmd->filter->dump(cmd->filter, 0);
+	    cmd->dump_filter && cmd->filter && cmd->filter->dump &&
+	    !cmd->filter->dump(cmd->filter, 0))
+		stack;
 
 	r = 1;
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 00887ab..c409f2a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1652,8 +1652,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	struct dm_config_tree *cft_cmdline;
 	FILE *new_stream;
 
-	if (cmd->dump_filter && cmd->filter && cmd->filter->dump)
-		cmd->filter->dump(cmd->filter, 1);
+	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
+	    !cmd->filter->dump(cmd->filter, 1))
+		stack;
 
 	archive_exit(cmd);
 	backup_exit(cmd);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index b886098..0d342c5 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -26,7 +26,7 @@ struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
 	void (*wipe) (struct dev_filter * f);
-	void (*dump) (struct dev_filter * f, int merge_existing);
+	int (*dump) (struct dev_filter * f, int merge_existing);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index bc37213..1229460 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -49,15 +49,16 @@ static void _composite_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-static void _dump(struct dev_filter *f, int merge_existing)
+static int _dump(struct dev_filter *f, int merge_existing)
 {
-	struct dev_filter **filters = (struct dev_filter **) f->private;
+	struct dev_filter **filters;
 
-	while (*filters) {
-		if ((*filters)->dump)
-			(*filters)->dump(*filters, merge_existing);
-		filters++;
-	}
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
+		if ((*filters)->dump &&
+		    !(*filters)->dump(*filters, merge_existing))
+			return_0;
+
+	return 1;
 }
 
 static void _wipe(struct dev_filter *f)


