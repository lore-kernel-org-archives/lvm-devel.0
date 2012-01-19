From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:31:47 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c lib/ ...
Message-ID: <20120119153147.30351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:31:46

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c import_vsn1.c 
	lib/metadata   : lv.c lv.h lv_manip.c vg.c vg.h 

Log message:
	Add support to keep info about creation time and host for each LV
	
	Basic support to keep info when the LV was created.
	Host and time is stored into LV mda section.
	
	FIXME: Current version doesn't support configurable string via lvm.conf
	and used fixed version strftime "%Y-%m-%d %T %z".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2222&r2=1.2223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.341&r2=1.342
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2012/01/12 18:29:07	1.2222
+++ LVM2/WHATS_NEW	2012/01/19 15:31:45	1.2223
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Keep into about creation host and time for each logical volume.
   Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
   Show read-only activation override in lvdisplay & add 4 to perms in -c.
--- LVM2/lib/format_text/export.c	2011/09/01 10:25:22	1.84
+++ LVM2/lib/format_text/export.c	2012/01/19 15:31:45	1.85
@@ -579,6 +579,8 @@
 	struct lv_segment *seg;
 	char buffer[4096];
 	int seg_count;
+	struct tm *local_tm;
+	time_t ts;
 
 	outnl(f);
 	outf(f, "%s {", lv->name);
@@ -596,6 +598,19 @@
 	if (!_out_tags(f, &lv->tags))
 		return_0;
 
+	if (lv->timestamp) {
+		ts = (time_t)lv->timestamp;
+		strncpy(buffer, "# ", sizeof(buffer));
+		if (!(local_tm = localtime(&ts)) ||
+		    !strftime(buffer + 2, sizeof(buffer) - 2,
+			      "%Y-%m-%d %T %z", local_tm))
+			buffer[0] = 0;
+
+		outf(f, "creation_host = \"%s\"", lv->hostname);
+		outfc(f, buffer, "creation_time = %" PRIu64,
+		      lv->timestamp);
+	}
+
 	if (lv->alloc != ALLOC_INHERIT)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(lv->alloc));
--- LVM2/lib/format_text/import_vsn1.c	2012/01/19 15:17:46	1.97
+++ LVM2/lib/format_text/import_vsn1.c	2012/01/19 15:31:45	1.98
@@ -494,6 +494,8 @@
 	struct logical_volume *lv;
 	const char *lv_alloc;
 	const struct dm_config_value *cv;
+	const char *hostname;
+	uint64_t timestamp = 0;
 
 	if (!(lv = alloc_lv(mem)))
 		return_0;
@@ -512,6 +514,23 @@
 		return 0;
 	}
 
+	if (dm_config_has_node(lvn, "creation_time")) {
+		if (!_read_uint64(lvn, "creation_time", &timestamp)) {
+			log_error("Invalid creation_time for logical volume %s.",
+				  lv->name);
+			return 0;
+		}
+		if (!dm_config_get_str(lvn, "creation_host", &hostname)) {
+			log_error("Couldn't read creation_host for logical volume %s.",
+				  lv->name);
+			return 0;
+		}
+	} else if (dm_config_has_node(lvn, "creation_host")) {
+		log_error("Missing creation_time for logical volume %s.",
+			  lv->name);
+		return 0;
+	}
+
 	lv->alloc = ALLOC_INHERIT;
 	if (dm_config_get_str(lvn, "allocation_policy", &lv_alloc)) {
 		lv->alloc = get_alloc_from_string(lv_alloc);
@@ -548,7 +567,13 @@
 	if (!dm_hash_insert(lv_hash, lv->name, lv))
 		return_0;
 
-	return link_lv_to_vg(vg, lv);
+	if (!link_lv_to_vg(vg, lv))
+		return_0;
+
+	if (timestamp && !lv_set_creation(lv, hostname, timestamp))
+		return_0;
+
+	return 1;
 }
 
 static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
--- LVM2/lib/metadata/lv.c	2012/01/12 16:58:44	1.30
+++ LVM2/lib/metadata/lv.c	2012/01/19 15:31:45	1.31
@@ -21,6 +21,12 @@
 #include "segtype.h"
 #include "str_list.h"
 
+#include <time.h>
+#include <sys/utsname.h>
+
+static struct utsname _utsname;
+static int _utsinit = 0;
+
 static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			     int range_format)
 {
@@ -469,3 +475,58 @@
 out:
 	return repstr;
 }
+
+int lv_set_creation(struct logical_volume *lv,
+		    const char *hostname, uint64_t timestamp)
+{
+	const char *hn;
+
+	if (!hostname) {
+		if (!_utsinit) {
+			if (uname(&_utsname)) {
+				log_error("uname failed: %s", strerror(errno));
+				memset(&_utsname, 0, sizeof(_utsname));
+			}
+
+			_utsinit = 1;
+		}
+
+		hostname = _utsname.nodename;
+	}
+
+	if (!(hn = dm_hash_lookup(lv->vg->hostnames, hostname))) {
+		if (!(hn = dm_pool_strdup(lv->vg->vgmem, hostname))) {
+			log_error("Failed to duplicate hostname");
+			return 0;
+		}
+
+		if (!dm_hash_insert(lv->vg->hostnames, hostname, (void*)hn))
+			return_0;
+	}
+
+	lv->hostname = hn;
+	lv->timestamp = timestamp ? : time(NULL);
+
+	return 1;
+}
+
+char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	char buffer[50];
+	struct tm *local_tm;
+	time_t ts = (time_t)lv->timestamp;
+
+	if (!ts ||
+	    !(local_tm = localtime(&ts)) ||
+	    /* FIXME: make this lvm.conf configurable */
+	    !strftime(buffer, sizeof(buffer),
+		      "%Y-%m-%d %T %z", local_tm))
+		buffer[0] = 0;
+
+	return dm_pool_strdup(mem, buffer);
+}
+
+char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return dm_pool_strdup(mem, lv->hostname ? : "");
+}
--- LVM2/lib/metadata/lv.h	2011/09/09 00:54:49	1.21
+++ LVM2/lib/metadata/lv.h	2012/01/19 15:31:45	1.22
@@ -46,6 +46,9 @@
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
+
+	uint64_t timestamp;
+	const char *hostname;
 };
 
 uint64_t lv_size(const struct logical_volume *lv);
@@ -71,5 +74,8 @@
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
-
+char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
+int lv_set_creation(struct logical_volume *lv,
+		    const char *hostname, uint64_t timestamp);
 #endif /* _LVM_LV_H */
--- LVM2/lib/metadata/lv_manip.c	2012/01/19 15:23:50	1.341
+++ LVM2/lib/metadata/lv_manip.c	2012/01/19 15:31:45	1.342
@@ -2993,6 +2993,9 @@
 
 	if (!link_lv_to_vg(vg, lv))
 		goto_bad;
+
+	if (!lv_set_creation(lv, NULL, 0))
+		goto_bad;
  
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
 		goto_bad;
--- LVM2/lib/metadata/vg.c	2011/11/04 22:49:53	1.13
+++ LVM2/lib/metadata/vg.c	2012/01/19 15:31:45	1.14
@@ -44,6 +44,12 @@
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
 
+	if (!(vg->hostnames = dm_hash_create(16))) {
+		log_error("Failed to allocate VG hostname hashtable.");
+		dm_pool_destroy(vgmem);
+		return NULL;
+	}
+
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->pvs_to_create);
 	dm_list_init(&vg->lvs);
@@ -67,6 +73,7 @@
 
 	log_debug("Freeing VG %s at %p.", vg->name, vg);
 
+	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
 }
 
--- LVM2/lib/metadata/vg.h	2011/11/04 22:49:53	1.16
+++ LVM2/lib/metadata/vg.h	2012/01/19 15:31:45	1.17
@@ -109,6 +109,8 @@
 	 */
 	uint32_t read_status;
 	uint32_t mda_copies; /* target number of mdas for this VG */
+
+	struct dm_hash_table *hostnames; /* map of creation hostnames */
 };
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,


