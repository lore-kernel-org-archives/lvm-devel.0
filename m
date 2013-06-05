From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:40 +0000 (UTC)
Subject: dev-mornfall-lvmcache - filters: update composable filter
Message-ID: <20130605120540.A183060E50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5467a3b2b70a2550eb84423a20873ad7d520907b
Commit:        5467a3b2b70a2550eb84423a20873ad7d520907b
Parent:        20868482dd12ab2bc77ba57d6c159fb80ad56a94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 2 21:59:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 22:46:06 2013 +0200

filters: update composable filter

Last commit made dump filter only partially composable.
Add remaining functionality and also support composable wipe,
which is needed, when i.e. vgscan needs to remove cache.

(in release fix)
---
 WHATS_NEW                       |    2 +-
 lib/cache/lvmcache.c            |    5 +++--
 lib/commands/toolcontext.c      |    2 +-
 lib/device/dev-cache.h          |    2 +-
 lib/filters/filter-composite.c  |   14 ++++++++++++--
 lib/filters/filter-persistent.c |    9 ++-------
 lib/filters/filter-persistent.h |    1 -
 7 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba88915..cd2d8ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
 Version 2.02.99 - 
 ===================================
   Do not use persistent filter with lvmetad.
-  Update persistent filter functinality for global filter.
+  Composable persistent filter functionality for global filter.
   Override system's global_filter settings for vgimportclone.
   Detect maximum usable size for snapshot for lvresize.
   Creation of snapshot takes at most 100% origin coverage.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 174c133..81b8de1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -707,8 +707,9 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	 * If we are a long-lived process, write out the updated persistent
 	 * device cache for the benefit of short-lived processes.
 	 */
-	if (full_scan == 2 && cmd->is_long_lived && cmd->dump_filter)
-		persistent_filter_dump(cmd->filter, 0);
+	if (full_scan == 2 && cmd->is_long_lived &&
+	    cmd->dump_filter && cmd->filter && cmd->filter->dump)
+		cmd->filter->dump(cmd->filter, 0);
 
 	r = 1;
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index af1aa63..00887ab 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1653,7 +1653,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	FILE *new_stream;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump)
-		cmd->filter->dump(cmd->filter);
+		cmd->filter->dump(cmd->filter, 1);
 
 	archive_exit(cmd);
 	backup_exit(cmd);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 4119d90..b886098 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -26,7 +26,7 @@ struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
 	void (*wipe) (struct dev_filter * f);
-	void (*dump) (struct dev_filter * f);
+	void (*dump) (struct dev_filter * f, int merge_existing);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 0d09c04..e183c00 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -49,17 +49,26 @@ static void _composite_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-static void _dump(struct dev_filter *f)
+static void _dump(struct dev_filter *f, int merge_existing)
 {
 	struct dev_filter **filters = (struct dev_filter **) f->private;
 
 	while (*filters) {
 		if ((*filters)->dump)
-			(*filters)->dump(*filters);
+			(*filters)->dump(*filters, merge_existing);
 		filters++;
 	}
 }
 
+static void _wipe(struct dev_filter *f)
+{
+	struct dev_filter **filters;
+
+	for (filters = f->private; *filters; filters++)
+		if ((*filters)->wipe)
+			(*filters)->wipe(*filters);
+}
+
 struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 {
 	struct dev_filter **filters_copy, *cft;
@@ -84,6 +93,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	cft->passes_filter = _and_p;
 	cft->destroy = _composite_destroy;
 	cft->dump = _dump;
+	cft->wipe = _wipe;
 	cft->use_count = 0;
 	cft->private = filters_copy;
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 7288d9d..799e7d8 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -179,7 +179,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 		fprintf(fp, "\n\t]\n");
 }
 
-int persistent_filter_dump(struct dev_filter *f, int merge_existing)
+static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 {
 	struct pfilter *pf;
 	char *tmp_file;
@@ -274,11 +274,6 @@ out:
 	return r;
 }
 
-static void _dump(struct dev_filter *f)
-{
-	persistent_filter_dump(f, 1);
-}
-
 static int _lookup_p(struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
@@ -372,7 +367,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	f->use_count = 0;
 	f->private = pf;
 	f->wipe = _persistent_filter_wipe;
-	f->dump = _dump;
+	f->dump = _persistent_filter_dump;
 
 	return f;
 
diff --git a/lib/filters/filter-persistent.h b/lib/filters/filter-persistent.h
index c2eee30..58fbc10 100644
--- a/lib/filters/filter-persistent.h
+++ b/lib/filters/filter-persistent.h
@@ -22,6 +22,5 @@ struct dev_filter *persistent_filter_create(struct dev_filter *f,
 					    const char *file);
 
 int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
-int persistent_filter_dump(struct dev_filter *f, int merge_existing);
 
 #endif


