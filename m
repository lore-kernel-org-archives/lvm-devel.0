From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Sep 2010 01:36:16 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100922013616.31676.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-22 01:36:14

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/cache      : lvmcache.c 
	lib/device     : dev-cache.c dev-cache.h 
	lib/filters    : filter-composite.c filter-md.c 
	                 filter-persistent.c filter-regex.c 
	                 filter-sysfs.c filter.c 

Log message:
	Track recursive filter iteration to avoid refreshing while in use. (2.02.56)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.253&r2=1.254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1731&r2=1.1732
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.413&r2=1.414
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-composite.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-md.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/VERSION	2010/08/25 11:25:02	1.253
+++ LVM2/VERSION	2010/09/22 01:36:13	1.254
@@ -1 +1 @@
-2.02.74(2)-cvs (2010-08-19)
+2.02.74(2)-cvs (2010-09-22)
--- LVM2/VERSION_DM	2010/08/19 22:33:14	1.62
+++ LVM2/VERSION_DM	2010/09/22 01:36:13	1.63
@@ -1 +1 @@
-1.02.55-cvs (2010-08-19)
+1.02.55-cvs (2010-09-22)
--- LVM2/WHATS_NEW	2010/09/20 14:25:27	1.1731
+++ LVM2/WHATS_NEW	2010/09/22 01:36:13	1.1732
@@ -1,7 +1,8 @@
 Version 2.02.74 - 
-==================================
-  Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function.
-  Use dynamic allocation for metadata's tag buffer (removes 4096 char. limit).
+=====================================
+  Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
+  Revert to old glibc vsnprintf behaviour in emit_to_buffer() to catch overflow.
+  Allocate buffer for metadata tags dynamically to remove 4k limit.
   Add random suffix to archive file names to prevent races when being created.
   Reinitialize archive and backup handling on toolcontext refresh.
   Fix opprobriously slow I/O to cluster mirrors created with --nosync.
@@ -16,16 +17,16 @@
   Add "devices/default_data_alignment" to lvm.conf.
   Add implmentation for simple numeric 'get' property functions.
   Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' function
-  Add properties.[ch] to lib/report, defined based on columns.h.
+  Add properties.[ch] to lib/report using columns.h.
   Add macro definitions to report infrastructure for character array length.
   Remove explicit double quotes from columns.h 'id' entries.
   Add 'flags' field to columns.h and define FIELD_MODIFIABLE.
   Add vg_mda_size and vg_mda_free functions.
   Simplify MD/swap signature detection in pvcreate and allow aborting.
-  Remove assumption that --yes must be used only in --force mode.
+  Allow --yes to be used without --force mode.
   Fix file descriptor leak in swap signature detection error path.
   Detect and allow abort in pvcreate if LUKS signature is detected.
-  Use proper locks mask when checking for LCK_WRITE.
+  Always mask lock flags correctly when checking for LCK_WRITE.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/WHATS_NEW_DM	2010/08/19 22:33:14	1.413
+++ LVM2/WHATS_NEW_DM	2010/09/22 01:36:13	1.414
@@ -1,5 +1,6 @@
 Version 1.02.55 - 
-==================================
+=====================================
+  Add DM_REPORT_FIELD_TYPE_ID_LEN to libdevmapper.h.
 
 Version 1.02.54 - 18th August 2010
 ==================================
--- LVM2/lib/cache/lvmcache.c	2010/07/09 15:34:42	1.93
+++ LVM2/lib/cache/lvmcache.c	2010/09/22 01:36:14	1.94
@@ -570,7 +570,7 @@
 		goto out;
 	}
 
-	if (full_scan == 2 && !refresh_filters(cmd)) {
+	if (full_scan == 2 && !cmd->filter->use_count && !refresh_filters(cmd)) {
 		log_error("refresh filters failed");
 		goto out;
 	}
--- LVM2/lib/device/dev-cache.c	2010/08/03 13:39:27	1.58
+++ LVM2/lib/device/dev-cache.c	2010/09/22 01:36:14	1.59
@@ -815,12 +815,14 @@
 
 	di->current = btree_first(_cache.devices);
 	di->filter = f;
+	di->filter->use_count++;
 
 	return di;
 }
 
 void dev_iter_destroy(struct dev_iter *iter)
 {
+	iter->filter->use_count--;
 	dm_free(iter);
 }
 
--- LVM2/lib/device/dev-cache.h	2007/08/20 20:55:25	1.11
+++ LVM2/lib/device/dev-cache.h	2010/09/22 01:36:14	1.12
@@ -24,6 +24,7 @@
 struct dev_filter {
 	int (*passes_filter) (struct dev_filter * f, struct device * dev);
 	void (*destroy) (struct dev_filter * f);
+	unsigned use_count;
 	void *private;
 };
 
--- LVM2/lib/filters/filter-composite.c	2008/01/30 13:59:58	1.15
+++ LVM2/lib/filters/filter-composite.c	2010/09/22 01:36:14	1.16
@@ -37,6 +37,9 @@
 {
 	struct dev_filter **filters = (struct dev_filter **) f->private;
 
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying composite filter while in use %u times.", f->use_count);
+
 	while (*filters) {
 		(*filters)->destroy(*filters);
 		filters++;
@@ -69,6 +72,7 @@
 
 	cft->passes_filter = _and_p;
 	cft->destroy = _composite_destroy;
+	cft->use_count = 0;
 	cft->private = filters_copy;
 
 	return cft;
--- LVM2/lib/filters/filter-md.c	2010/07/09 15:34:43	1.9
+++ LVM2/lib/filters/filter-md.c	2010/09/22 01:36:14	1.10
@@ -45,6 +45,9 @@
 
 static void _destroy(struct dev_filter *f)
 {
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying sysfs filter while in use %u times.", f->use_count);
+
 	dm_free(f);
 }
 
@@ -59,6 +62,7 @@
 
 	f->passes_filter = _ignore_md;
 	f->destroy = _destroy;
+	f->use_count = 0;
 	f->private = NULL;
 
 	return f;
--- LVM2/lib/filters/filter-persistent.c	2010/08/09 14:05:18	1.44
+++ LVM2/lib/filters/filter-persistent.c	2010/09/22 01:36:14	1.45
@@ -274,13 +274,13 @@
 		return 0;
 	}
 
-        /* Test dm devices every time, so cache them as GOOD. */
+	/* Test dm devices every time, so cache them as GOOD. */
 	if (MAJOR(dev->dev) == dm_major()) {
 		if (!l)
 			dm_list_iterate_items(sl, &dev->aliases)
 				dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE);
 		if (!device_is_usable(dev)) {
-                	log_debug("%s: Skipping unusable device", dev_name(dev));
+			log_debug("%s: Skipping unusable device", dev_name(dev));
 			return 0;
 		}
 		return pf->real->passes_filter(pf->real, dev);
@@ -301,6 +301,9 @@
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying persistent filter while in use %u times.", f->use_count);
+
 	dm_hash_destroy(pf->devices);
 	dm_free(pf->file);
 	pf->real->destroy(pf->real);
@@ -339,6 +342,7 @@
 
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;
+	f->use_count = 0;
 	f->private = pf;
 
 	return f;
--- LVM2/lib/filters/filter-regex.c	2010/04/30 12:31:33	1.27
+++ LVM2/lib/filters/filter-regex.c	2010/09/22 01:36:14	1.28
@@ -181,6 +181,10 @@
 static void _regex_destroy(struct dev_filter *f)
 {
 	struct rfilter *rf = (struct rfilter *) f->private;
+
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying regex filter while in use %u times.", f->use_count);
+
 	dm_pool_destroy(rf->mem);
 }
 
@@ -206,6 +210,7 @@
 
 	f->passes_filter = _accept_p;
 	f->destroy = _regex_destroy;
+	f->use_count = 0;
 	f->private = rf;
 	return f;
 
--- LVM2/lib/filters/filter-sysfs.c	2010/07/09 15:34:43	1.21
+++ LVM2/lib/filters/filter-sysfs.c	2010/09/22 01:36:14	1.22
@@ -282,6 +282,10 @@
 static void _destroy(struct dev_filter *f)
 {
 	struct dev_set *ds = (struct dev_set *) f->private;
+
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying sysfs filter while in use %u times.", f->use_count);
+
 	dm_pool_destroy(ds->mem);
 }
 
@@ -316,6 +320,7 @@
 
 	f->passes_filter = _accept_p;
 	f->destroy = _destroy;
+	f->use_count = 0;
 	f->private = ds;
 	return f;
 
--- LVM2/lib/filters/filter.c	2010/08/11 12:14:24	1.56
+++ LVM2/lib/filters/filter.c	2010/09/22 01:36:14	1.57
@@ -326,6 +326,7 @@
 
 	f->passes_filter = _passes_lvm_type_device_filter;
 	f->destroy = lvm_type_filter_destroy;
+	f->use_count = 0;
 	f->private = NULL;
 
 	if (!_scan_proc_dev(proc, cn)) {
@@ -338,5 +339,8 @@
 
 void lvm_type_filter_destroy(struct dev_filter *f)
 {
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
+
 	dm_free(f);
 }


