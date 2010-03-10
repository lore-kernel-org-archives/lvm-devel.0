From: Milan Broz <mbroz@redhat.com>
Date: Wed, 10 Mar 2010 22:43:27 +0100
Subject: [PATCH] Fix segfault when destroying in-use filters in pvs -a.
Message-ID: <1268257407-16371-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Because pvs -a iterate throught the whole device cache
we should not refresh filters inside iteration.

Fix it by introducing simple reference counter and test
it in refresh_filters() call.

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=571963
---
 lib/commands/toolcontext.c      |    5 +++++
 lib/device/dev-cache.c          |    2 ++
 lib/device/dev-cache.h          |    1 +
 lib/filters/filter-composite.c  |    1 +
 lib/filters/filter-md.c         |    1 +
 lib/filters/filter-persistent.c |    1 +
 lib/filters/filter-regex.c      |    1 +
 lib/filters/filter-sysfs.c      |    1 +
 lib/filters/filter.c            |    1 +
 9 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7aac361..a78efe8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1240,6 +1240,11 @@ int refresh_filters(struct cmd_context *cmd)
 {
 	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
 
+	if (cmd->filter && cmd->filter->in_use) {
+		log_debug("Skipping filter refresh currently in use.");
+		return 1;
+	}
+
 	if (cmd->filter) {
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 45c0e8f..933d83a 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -743,12 +743,14 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 
 	di->current = btree_first(_cache.devices);
 	di->filter = f;
+	di->filter->in_use++;
 
 	return di;
 }
 
 void dev_iter_destroy(struct dev_iter *iter)
 {
+	iter->filter->in_use--;
 	dm_free(iter);
 }
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 96bf013..9314a5c 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -24,6 +24,7 @@
 struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
+	unsigned in_use;
 	void *private;
 };
 
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index d1606d3..55aedaf 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -70,6 +70,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	cft->passes_filter = _and_p;
 	cft->destroy = _composite_destroy;
 	cft->private = filters_copy;
+	cft->in_use = 0;
 
 	return cft;
 }
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index c1ecff7..0e9857d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -60,6 +60,7 @@ struct dev_filter *md_filter_create(void)
 	f->passes_filter = _ignore_md;
 	f->destroy = _destroy;
 	f->private = NULL;
+	f->in_use = 0;
 
 	return f;
 }
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 9243a94..3c7639c 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -317,6 +317,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;
 	f->private = pf;
+	f->in_use = 0;
 
 	return f;
 
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 1d415a4..7903314 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -207,6 +207,7 @@ struct dev_filter *regex_filter_create(struct config_value *patterns)
 	f->passes_filter = _accept_p;
 	f->destroy = _regex_destroy;
 	f->private = rf;
+	f->in_use = 0;
 	return f;
 
       bad:
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 1220b3a..30e29b3 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -317,6 +317,7 @@ struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
 	f->passes_filter = _accept_p;
 	f->destroy = _destroy;
 	f->private = ds;
+	f->in_use = 0;
 	return f;
 
  bad:
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index b33d099..7e3edfe 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -319,6 +319,7 @@ struct dev_filter *lvm_type_filter_create(const char *proc,
 	f->passes_filter = _passes_lvm_type_device_filter;
 	f->destroy = lvm_type_filter_destroy;
 	f->private = NULL;
+	f->in_use = 0;
 
 	if (!_scan_proc_dev(proc, cn)) {
 		dm_free(f);
-- 
1.7.0


