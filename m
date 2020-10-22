From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:11 +0000 (GMT)
Subject: master - filters: allow filter wipe for one device
Message-ID: <20201022204311.0E02F385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c601ec0d6ed0a1cf31cdf65b995e7b3f0b6f1d72
Commit:        c601ec0d6ed0a1cf31cdf65b995e7b3f0b6f1d72
Parent:        83d08185234748f1837436d83cbf6817180551fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 20 15:17:56 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

filters: allow filter wipe for one device

as passes_filter already does
---
 lib/device/dev-cache.h          |  2 +-
 lib/filters/filter-composite.c  |  9 ++++++---
 lib/filters/filter-persistent.c | 10 ++++++++--
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 533e4561d..7285bc3a7 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -28,7 +28,7 @@ struct cmd_context;
 struct dev_filter {
 	int (*passes_filter) (struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name);
 	void (*destroy) (struct dev_filter *f);
-	void (*wipe) (struct dev_filter *f);
+	void (*wipe) (struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name);
 	void *private;
 	unsigned use_count;
 	const char *name;
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index b0063f149..f4cbeefe8 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -60,13 +60,16 @@ static void _composite_destroy(struct dev_filter *f)
 	free(f);
 }
 
-static void _wipe(struct dev_filter *f)
+static void _wipe(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_filter **filters;
 
-	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters) {
+		if (use_filter_name && strcmp((*filters)->name, use_filter_name))
+			continue;
 		if ((*filters)->wipe)
-			(*filters)->wipe(*filters);
+			(*filters)->wipe(cmd, *filters, dev, use_filter_name);
+	}
 }
 
 struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters)
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index afa32d4b9..291f3932f 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -64,11 +64,17 @@ static int _init_hash(struct pfilter *pf)
 	return 1;
 }
 
-static void _persistent_filter_wipe(struct dev_filter *f)
+static void _persistent_filter_wipe(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
+	struct dm_str_list *sl;
 
-	dm_hash_wipe(pf->devices);
+	if (!dev) {
+		dm_hash_wipe(pf->devices);
+	} else {
+		dm_list_iterate_items(sl, &dev->aliases)
+			dm_hash_remove(pf->devices, sl->str);
+	}
 }
 
 static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)


