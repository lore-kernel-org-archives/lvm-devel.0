From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:08:08 -0000
Subject: LVM2/lib metadata/metadata.c metadata/metadata ...
Message-ID: <20100930140808.17267.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:08:07

Modified files:
	lib/metadata   : metadata.c metadata.h 
	lib/report     : report.c 

Log message:
	Add tags_format_and_copy() common function and call from _tags_disp.
	
	Add a common function to allocate memory and format a string of
	tags.
	Call tags_format_and_copy() from _tags_disp().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.401&r2=1.402
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/metadata/metadata.c	2010/09/30 13:52:56	1.401
+++ LVM2/lib/metadata/metadata.c	2010/09/30 14:08:07	1.402
@@ -3937,6 +3937,30 @@
 	}
 }
 
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
+{
+	struct str_list *sl;
+
+	if (!dm_pool_begin_object(mem, 256)) {
+		log_error("dm_pool_begin_object failed");
+		return NULL;
+	}
+
+	dm_list_iterate_items(sl, tags) {
+		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
+		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
+			log_error("dm_pool_grow_object failed");
+			return NULL;
+		}
+	}
+
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
+		log_error("dm_pool_grow_object failed");
+		return NULL;
+	}
+	return dm_pool_end_object(mem);
+}
+
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
--- LVM2/lib/metadata/metadata.h	2010/09/30 13:52:56	1.220
+++ LVM2/lib/metadata/metadata.h	2010/09/30 14:08:07	1.221
@@ -413,5 +413,6 @@
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char alloc_policy_char(alloc_policy_t alloc);
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
 #endif
--- LVM2/lib/report/report.c	2010/09/30 14:07:33	1.129
+++ LVM2/lib/report/report.c	2010/09/30 14:08:07	1.130
@@ -150,27 +150,12 @@
 		      const void *data, void *private __attribute__((unused)))
 {
 	const struct dm_list *tags = (const struct dm_list *) data;
-	struct str_list *sl;
+	char *tags_str;
 
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
+	if (!(tags_str = tags_format_and_copy(mem, tags)))
 		return 0;
-	}
-
-	dm_list_iterate_items(sl, tags) {
-		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
-		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
-			log_error("dm_pool_grow_object failed");
-			return 0;
-		}
-	}
-
-	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
-		return 0;
-	}
 
-	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
+	dm_report_field_set_value(field, tags_str, NULL);
 
 	return 1;
 }


