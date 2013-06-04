From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:15 +0000 (UTC)
Subject: dev-mornfall-activate - filters: toplevel filter not persistent
Message-ID: <20130604192815.9D1DE61434@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7878da9216945c3209a430d8b01038312d911bd
Commit:        e7878da9216945c3209a430d8b01038312d911bd
Parent:        05bf4b8cc3e3d15e79c9964e496dbe396beacb3c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 00:49:40 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:48:58 2013 +0200

filters: toplevel filter not persistent

Add a generic dump operation to filters and make the composite filter call
through to its components. Previously, when global filter was set, the code
would treat the toplevel composite filter's private area as if it belonged a
persistent filter, trying to write nonsense into a non-sensical file.
Also deal with NULL cmd->filter gracefully.
---
 WHATS_NEW                       |    1 +
 lib/commands/toolcontext.c      |    4 ++--
 lib/device/dev-cache.h          |    1 +
 lib/filters/filter-composite.c  |   12 ++++++++++++
 lib/filters/filter-persistent.c |    6 ++++++
 5 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56868b7..748c3fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Update persistent filter functinality for global filter.
   Override system's global_filter settings for vgimportclone.
   Detect maximum usable size for snapshot for lvresize.
   Creation of snapshot takes at most 100% origin coverage.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 5c1719b..965ba4a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1650,8 +1650,8 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	struct dm_config_tree *cft_cmdline;
 	FILE *new_stream;
 
-	if (cmd->dump_filter)
-		persistent_filter_dump(cmd->filter, 1);
+	if (cmd->dump_filter && cmd->filter && cmd->filter->dump)
+		cmd->filter->dump(cmd->filter);
 
 	archive_exit(cmd);
 	backup_exit(cmd);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 3267c9d..4119d90 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -26,6 +26,7 @@ struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
 	void (*wipe) (struct dev_filter * f);
+	void (*dump) (struct dev_filter * f);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 2298000..0d09c04 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -49,6 +49,17 @@ static void _composite_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
+static void _dump(struct dev_filter *f)
+{
+	struct dev_filter **filters = (struct dev_filter **) f->private;
+
+	while (*filters) {
+		if ((*filters)->dump)
+			(*filters)->dump(*filters);
+		filters++;
+	}
+}
+
 struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 {
 	struct dev_filter **filters_copy, *cft;
@@ -72,6 +83,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 
 	cft->passes_filter = _and_p;
 	cft->destroy = _composite_destroy;
+	cft->dump = _dump;
 	cft->use_count = 0;
 	cft->private = filters_copy;
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 0d53fce..7288d9d 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -274,6 +274,11 @@ out:
 	return r;
 }
 
+static void _dump(struct dev_filter *f)
+{
+	persistent_filter_dump(f, 1);
+}
+
 static int _lookup_p(struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
@@ -367,6 +372,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	f->use_count = 0;
 	f->private = pf;
 	f->wipe = _persistent_filter_wipe;
+	f->dump = _dump;
 
 	return f;
 


