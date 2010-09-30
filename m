From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Sep 2010 21:06:55 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c l ...
Message-ID: <20100930210655.12746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-30 21:06:53

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c 
	lib/filters    : filter-persistent.c 
	lib/format1    : disk-rep.c format1.c import-export.c 
	lib/format_text: export.c 
	lib/label      : label.c 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 
	                 libdm-report.c 
	libdm/datastruct: bitset.c hash.c 
	libdm/mm       : dbg_malloc.c pool-fast.c 
	libdm/regex    : matcher.c 
	tools          : dmsetup.c 

Log message:
	Add dm_zalloc and use it and dm_pool_zalloc throughout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1743&r2=1.1744
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/hash.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/WHATS_NEW	2010/09/30 14:26:48	1.1743
+++ LVM2/WHATS_NEW	2010/09/30 21:06:50	1.1744
@@ -1,8 +1,9 @@
 Version 2.02.75 - 
 =====================================
+  Add dm_zalloc and use it and dm_pool_zalloc throughout.
   Add pv_get_property and create generic internal _get_property function.
   Add 'get' functions for pv and vg properties/fields.
-  Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
+  Make generic GET_*_PROPERTY_FN macros with secondary macro for vg, pv & lv.
   Add tags_format_and_copy() common function and call from _tags_disp.
   Add id_format_and_copy() common function and call from _uuid_disp.
   Simplify logic to create '{pv|vg|lv}_attr' strings.
--- LVM2/daemons/dmeventd/dmeventd.c	2010/08/16 18:19:46	1.65
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/09/30 21:06:50	1.66
@@ -223,12 +223,11 @@
 static struct thread_status *_alloc_thread_status(struct message_data *data,
 						  struct dso_data *dso_data)
 {
-	struct thread_status *ret = (typeof(ret)) dm_malloc(sizeof(*ret));
+	struct thread_status *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
 
 	if (!ret)
 		return NULL;
 
-	memset(ret, 0, sizeof(*ret));
 	if (!(ret->device.uuid = dm_strdup(data->device_uuid))) {
 		dm_free(ret);
 		return NULL;
@@ -259,12 +258,11 @@
 /* Allocate/free DSO data. */
 static struct dso_data *_alloc_dso_data(struct message_data *data)
 {
-	struct dso_data *ret = (typeof(ret)) dm_malloc(sizeof(*ret));
+	struct dso_data *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
 
 	if (!ret)
 		return NULL;
 
-	memset(ret, 0, sizeof(*ret));
 	if (!(ret->dso_name = dm_strdup(data->dso_name))) {
 		dm_free(ret);
 		return NULL;
--- LVM2/lib/cache/lvmcache.c	2010/09/22 01:36:14	1.94
+++ LVM2/lib/cache/lvmcache.c	2010/09/30 21:06:51	1.95
@@ -1064,11 +1064,10 @@
 			}
 		} else {
 ***/
-		if (!(vginfo = dm_malloc(sizeof(*vginfo)))) {
+		if (!(vginfo = dm_zalloc(sizeof(*vginfo)))) {
 			log_error("lvmcache_update_vgname: list alloc failed");
 			return 0;
 		}
-		memset(vginfo, 0, sizeof(*vginfo));
 		if (!(vginfo->vgname = dm_strdup(vgname))) {
 			dm_free(vginfo);
 			log_error("cache vgname alloc failed for %s", vgname);
@@ -1261,12 +1260,11 @@
 	    !(existing = info_from_pvid(dev->pvid, 0))) {
 		if (!(label = label_create(labeller)))
 			return_NULL;
-		if (!(info = dm_malloc(sizeof(*info)))) {
+		if (!(info = dm_zalloc(sizeof(*info)))) {
 			log_error("lvmcache_info allocation failed");
 			label_destroy(label);
 			return NULL;
 		}
-		memset(info, 0, sizeof(*info));
 
 		label->info = info;
 		info->label = label;
--- LVM2/lib/commands/toolcontext.c	2010/09/09 13:07:14	1.104
+++ LVM2/lib/commands/toolcontext.c	2010/09/30 21:06:51	1.105
@@ -1121,11 +1121,10 @@
 
 	init_syslog(DEFAULT_LOG_FACILITY);
 
-	if (!(cmd = dm_malloc(sizeof(*cmd)))) {
+	if (!(cmd = dm_zalloc(sizeof(*cmd)))) {
 		log_error("Failed to allocate command context");
 		return NULL;
 	}
-	memset(cmd, 0, sizeof(*cmd));
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
--- LVM2/lib/config/config.c	2010/09/27 19:09:34	1.81
+++ LVM2/lib/config/config.c	2010/09/30 21:06:51	1.82
@@ -724,6 +724,8 @@
 {
 	int values_allowed = 0;
 
+	const char *te;
+
 	p->tb = p->te;
 	_eat_space(p);
 	if (p->tb == p->fe || !*p->tb) {
@@ -738,59 +740,61 @@
 
 	p->t = TOK_INT;		/* fudge so the fall through for
 				   floats works */
-	switch (*p->te) {
+
+	te = p->te;
+	switch (*te) {
 	case SECTION_B_CHAR:
 		p->t = TOK_SECTION_B;
-		p->te++;
+		te++;
 		break;
 
 	case SECTION_E_CHAR:
 		p->t = TOK_SECTION_E;
-		p->te++;
+		te++;
 		break;
 
 	case '[':
 		p->t = TOK_ARRAY_B;
-		p->te++;
+		te++;
 		break;
 
 	case ']':
 		p->t = TOK_ARRAY_E;
-		p->te++;
+		te++;
 		break;
 
 	case ',':
 		p->t = TOK_COMMA;
-		p->te++;
+		te++;
 		break;
 
 	case '=':
 		p->t = TOK_EQ;
-		p->te++;
+		te++;
 		break;
 
 	case '"':
 		p->t = TOK_STRING_ESCAPED;
-		p->te++;
-		while ((p->te != p->fe) && (*p->te) && (*p->te != '"')) {
-			if ((*p->te == '\\') && (p->te + 1 != p->fe) &&
-			    *(p->te + 1))
-				p->te++;
-			p->te++;
+		te++;
+		while ((te != p->fe) && (*te) && (*te != '"')) {
+			if ((*te == '\\') && (te + 1 != p->fe) &&
+			    *(te + 1))
+				te++;
+			te++;
 		}
 
-		if ((p->te != p->fe) && (*p->te))
-			p->te++;
+		if ((te != p->fe) && (*te))
+			te++;
 		break;
 
 	case '\'':
 		p->t = TOK_STRING;
-		p->te++;
-		while ((p->te != p->fe) && (*p->te) && (*p->te != '\''))
-			p->te++;
+		te++;
+		while ((te != p->fe) && (*te) && (*te != '\''))
+			te++;
 
-		if ((p->te != p->fe) && (*p->te))
-			p->te++;
+		if ((te != p->fe) && (*te))
+			te++;
 		break;
 
 	case '.':
@@ -808,28 +812,30 @@
 	case '+':
 	case '-':
 		if (values_allowed) {
-			p->te++;
-			while ((p->te != p->fe) && (*p->te)) {
-				if (*p->te == '.') {
+			te++;
+			while ((te != p->fe) && (*te)) {
+				if (*te == '.') {
 					if (p->t == TOK_FLOAT)
 						break;
 					p->t = TOK_FLOAT;
-				} else if (!isdigit((int) *p->te))
+				} else if (!isdigit((int) *te))
 					break;
-				p->te++;
+				te++;
 			}
 			break;
 		}
 
 	default:
 		p->t = TOK_IDENTIFIER;
-		while ((p->te != p->fe) && (*p->te) && !isspace(*p->te) &&
-		       (*p->te != '#') && (*p->te != '=') &&
-		       (*p->te != SECTION_B_CHAR) &&
-		       (*p->te != SECTION_E_CHAR))
-			p->te++;
+		while ((te != p->fe) && (*te) && !isspace(*te) &&
+		       (*te != '#') && (*te != '=') &&
+		       (*te != SECTION_B_CHAR) &&
+		       (*te != SECTION_E_CHAR))
+			te++;
 		break;
 	}
+
+	p->te = te;
 }
 
 static void _eat_space(struct parser *p)
@@ -859,22 +865,12 @@
  */
 static struct config_value *_create_value(struct dm_pool *mem)
 {
-	struct config_value *v = dm_pool_alloc(mem, sizeof(*v));
-
-	if (v)
-		memset(v, 0, sizeof(*v));
-
-	return v;
+	return dm_pool_zalloc(mem, sizeof(struct config_value));
 }
 
 static struct config_node *_create_node(struct dm_pool *mem)
 {
-	struct config_node *n = dm_pool_alloc(mem, sizeof(*n));
-
-	if (n)
-		memset(n, 0, sizeof(*n));
-
-	return n;
+	return dm_pool_zalloc(mem, sizeof(struct config_node));
 }
 
 static char *_dup_tok(struct parser *p)
--- LVM2/lib/filters/filter-persistent.c	2010/09/22 01:36:14	1.45
+++ LVM2/lib/filters/filter-persistent.c	2010/09/30 21:06:51	1.46
@@ -318,9 +318,8 @@
 	struct dev_filter *f = NULL;
 	struct stat info;
 
-	if (!(pf = dm_malloc(sizeof(*pf))))
+	if (!(pf = dm_zalloc(sizeof(*pf))))
 		return_NULL;
-	memset(pf, 0, sizeof(*pf));
 
 	if (!(pf->file = dm_malloc(strlen(file) + 1)))
 		goto_bad;
--- LVM2/lib/format1/disk-rep.c	2010/07/09 15:34:44	1.81
+++ LVM2/lib/format1/disk-rep.c	2010/09/30 21:06:51	1.82
@@ -624,13 +624,12 @@
 	/* Make sure that the gap between the PV structure and
 	   the next one is zeroed in order to make non LVM tools
 	   happy (idea from AED) */
-	buf = dm_malloc(size);
+	buf = dm_zalloc(size);
 	if (!buf) {
 		log_error("Couldn't allocate temporary PV buffer.");
 		return 0;
 	}
 
-	memset(buf, 0, size);
 	memcpy(buf, &data->pvd, sizeof(struct pv_disk));
 
 	log_debug("Writing %s PV metadata to %s at %" PRIu64 " len %"
--- LVM2/lib/format1/format1.c	2010/09/22 13:45:22	1.122
+++ LVM2/lib/format1/format1.c	2010/09/30 21:06:51	1.123
@@ -157,7 +157,7 @@
 				      struct dm_list *pvs,
 				      struct dm_pool *mem)
 {
-	struct volume_group *vg = dm_pool_alloc(mem, sizeof(*vg));
+	struct volume_group *vg = dm_pool_zalloc(mem, sizeof(*vg));
 	struct disk_list *dl;
 
 	if (!vg)
@@ -166,8 +166,6 @@
 	if (dm_list_empty(pvs))
 		goto_bad;
 
-	memset(vg, 0, sizeof(*vg));
-
 	vg->cmd = fid->fmt->cmd;
 	vg->vgmem = mem;
 	vg->fid = fid;
--- LVM2/lib/format1/import-export.c	2010/07/09 15:34:44	1.114
+++ LVM2/lib/format1/import-export.c	2010/09/30 21:06:51	1.115
@@ -506,9 +506,8 @@
 	 * setup the pv's extents array
 	 */
 	len = sizeof(struct pe_disk) * dl->pvd.pe_total;
-	if (!(dl->extents = dm_pool_alloc(dl->mem, len)))
+	if (!(dl->extents = dm_pool_zalloc(dl->mem, len)))
 		goto_out;
-	memset(dl->extents, 0, len);
 
 	dm_list_iterate_items(ll, &vg->lvs) {
 		if (ll->lv->status & SNAPSHOT)
--- LVM2/lib/format_text/export.c	2010/09/20 14:23:20	1.78
+++ LVM2/lib/format_text/export.c	2010/09/30 21:06:51	1.79
@@ -742,10 +742,9 @@
 
 	_init();
 
-	if (!(f = dm_malloc(sizeof(*f))))
+	if (!(f = dm_zalloc(sizeof(*f))))
 		return_0;
 
-	memset(f, 0, sizeof(*f));
 	f->data.fp = fp;
 	f->indent = 0;
 	f->header = 1;
@@ -767,11 +766,9 @@
 
 	_init();
 
-	if (!(f = dm_malloc(sizeof(*f))))
+	if (!(f = dm_zalloc(sizeof(*f))))
 		return_0;
 
-	memset(f, 0, sizeof(*f));
-
 	f->data.buf.size = 65536;	/* Initial metadata limit */
 	if (!(f->data.buf.start = dm_malloc(f->data.buf.size))) {
 		log_error("text_export buffer allocation failed");
--- LVM2/lib/label/label.c	2010/09/27 19:09:35	1.51
+++ LVM2/lib/label/label.c	2010/09/30 21:06:52	1.52
@@ -383,11 +383,10 @@
 {
 	struct label *label;
 
-	if (!(label = dm_malloc(sizeof(*label)))) {
+	if (!(label = dm_zalloc(sizeof(*label)))) {
 		log_error("label allocaction failed");
 		return NULL;
 	}
-	memset(label, 0, sizeof(*label));
 
 	label->labeller = labeller;
 
--- LVM2/libdm/libdevmapper.h	2010/08/20 12:44:30	1.125
+++ LVM2/libdm/libdevmapper.h	2010/09/30 21:06:52	1.126
@@ -511,6 +511,8 @@
 
 void *dm_malloc_aux(size_t s, const char *file, int line);
 void *dm_malloc_aux_debug(size_t s, const char *file, int line);
+void *dm_zalloc_aux(size_t s, const char *file, int line);
+void *dm_zalloc_aux_debug(size_t s, const char *file, int line);
 char *dm_strdup_aux(const char *str, const char *file, int line);
 void dm_free_aux(void *p);
 void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line);
@@ -520,6 +522,7 @@
 #ifdef DEBUG_MEM
 
 #  define dm_malloc(s) dm_malloc_aux_debug((s), __FILE__, __LINE__)
+#  define dm_zalloc(s) dm_zalloc_aux_debug((s), __FILE__, __LINE__)
 #  define dm_strdup(s) dm_strdup_aux((s), __FILE__, __LINE__)
 #  define dm_free(p) dm_free_aux(p)
 #  define dm_realloc(p, s) dm_realloc_aux(p, s, __FILE__, __LINE__)
@@ -529,6 +532,7 @@
 #else
 
 #  define dm_malloc(s) dm_malloc_aux((s), __FILE__, __LINE__)
+#  define dm_zalloc(s) dm_zalloc_aux((s), __FILE__, __LINE__)
 #  define dm_strdup(s) strdup(s)
 #  define dm_free(p) free(p)
 #  define dm_realloc(p, s) realloc(p, s)
--- LVM2/libdm/libdm-common.c	2010/08/03 13:06:36	1.99
+++ LVM2/libdm/libdm-common.c	2010/09/30 21:06:52	1.100
@@ -166,7 +166,7 @@
 
 struct dm_task *dm_task_create(int type)
 {
-	struct dm_task *dmt = dm_malloc(sizeof(*dmt));
+	struct dm_task *dmt = dm_zalloc(sizeof(*dmt));
 
 	if (!dmt) {
 		log_error("dm_task_create: malloc(%" PRIsize_t ") failed",
@@ -179,8 +179,6 @@
 		return NULL;
 	}
 
-	memset(dmt, 0, sizeof(*dmt));
-
 	dmt->type = type;
 	dmt->minor = -1;
 	dmt->major = -1;
--- LVM2/libdm/libdm-deptree.c	2010/07/09 15:34:47	1.85
+++ LVM2/libdm/libdm-deptree.c	2010/09/30 21:06:52	1.86
@@ -197,12 +197,11 @@
 {
 	struct dm_tree *dtree;
 
-	if (!(dtree = dm_malloc(sizeof(*dtree)))) {
+	if (!(dtree = dm_zalloc(sizeof(*dtree)))) {
 		log_error("dm_tree_create malloc failed");
 		return NULL;
 	}
 
-	memset(dtree, 0, sizeof(*dtree));
 	dtree->root.dtree = dtree;
 	dm_list_init(&dtree->root.uses);
 	dm_list_init(&dtree->root.used_by);
--- LVM2/libdm/libdm-report.c	2010/06/16 13:01:25	1.36
+++ LVM2/libdm/libdm-report.c	2010/09/30 21:06:52	1.37
@@ -571,11 +571,10 @@
 	struct dm_report *rh;
 	const struct dm_report_object_type *type;
 
-	if (!(rh = dm_malloc(sizeof(*rh)))) {
+	if (!(rh = dm_zalloc(sizeof(*rh)))) {
 		log_error("dm_report_init: dm_malloc failed");
 		return 0;
 	}
-	memset(rh, 0, sizeof(*rh));
 
 	/*
 	 * rh->report_types is updated in _parse_fields() and _parse_keys()
--- LVM2/libdm/datastruct/bitset.c	2010/07/08 12:16:16	1.11
+++ LVM2/libdm/datastruct/bitset.c	2010/09/30 21:06:52	1.12
@@ -26,8 +26,8 @@
 	
 	if (mem)
 		bs = dm_pool_zalloc(mem, size);
-	else if ((bs = dm_malloc(size)))
-		memset(bs, 0, size);
+	else
+		bs = dm_zalloc(size);
 
 	if (!bs)
 		return NULL;
--- LVM2/libdm/datastruct/hash.c	2010/07/09 15:34:47	1.11
+++ LVM2/libdm/datastruct/hash.c	2010/09/30 21:06:52	1.12
@@ -90,14 +90,10 @@
 {
 	size_t len;
 	unsigned new_size = 16u;
-	struct dm_hash_table *hc = dm_malloc(sizeof(*hc));
+	struct dm_hash_table *hc = dm_zalloc(sizeof(*hc));
 
-	if (!hc) {
-		stack;
-		return 0;
-	}
-
-	memset(hc, 0, sizeof(*hc));
+	if (!hc)
+		return_0;
 
 	/* round size hint up to a power of two */
 	while (new_size < size_hint)
--- LVM2/libdm/mm/dbg_malloc.c	2010/08/09 10:56:01	1.20
+++ LVM2/libdm/mm/dbg_malloc.c	2010/09/30 21:06:52	1.21
@@ -119,6 +119,16 @@
 	return nb + 1;
 }
 
+void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
+{
+	void *ptr = dm_malloc_aux_debug(s, file, line);
+
+	if (ptr)
+		memset(ptr, 0, s);
+
+	return ptr;
+}
+
 void dm_free_aux(void *p)
 {
 	char *ptr;
@@ -250,3 +260,13 @@
 
 	return malloc(s);
 }
+
+void *dm_zalloc_aux(size_t s, const char *file, int line)
+{
+	void *ptr = dm_malloc_aux(s, file, line);
+
+	if (ptr)
+		memset(ptr, 0, s);
+
+	return ptr;
+}
--- LVM2/libdm/mm/pool-fast.c	2010/08/09 10:56:01	1.9
+++ LVM2/libdm/mm/pool-fast.c	2010/09/30 21:06:52	1.10
@@ -43,14 +43,13 @@
 struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
 	size_t new_size = 1024;
-	struct dm_pool *p = dm_malloc(sizeof(*p));
+	struct dm_pool *p = dm_zalloc(sizeof(*p));
 
 	if (!p) {
 		log_error("Couldn't create memory pool %s (size %"
 			  PRIsize_t ")", name, sizeof(*p));
 		return 0;
 	}
-	memset(p, 0, sizeof(*p));
 
 	/* round chunk_hint up to the next power of 2 */
 	p->chunk_size = chunk_hint + sizeof(struct chunk);
--- LVM2/libdm/regex/matcher.c	2010/08/09 10:30:52	1.12
+++ LVM2/libdm/regex/matcher.c	2010/09/30 21:06:52	1.13
@@ -320,11 +320,9 @@
 	struct dm_regex *m;
 	struct dm_pool *scratch = mem;
 
-	if (!(m = dm_pool_alloc(mem, sizeof(*m))))
+	if (!(m = dm_pool_zalloc(mem, sizeof(*m))))
 		return_NULL;
 
-	memset(m, 0, sizeof(*m));
-
 	/* join the regexps together, delimiting with zero */
 	for (i = 0; i < num_patterns; i++)
 		len += strlen(patterns[i]) + 8;
--- LVM2/tools/dmsetup.c	2010/08/03 13:04:32	1.144
+++ LVM2/tools/dmsetup.c	2010/09/30 21:06:53	1.145
@@ -730,13 +730,11 @@
 	for (i = 0; i < argc; i++)
 		sz += strlen(argv[i]) + 1;
 
-	if (!(str = dm_malloc(sz))) {
+	if (!(str = dm_zalloc(sz))) {
 		err("message string allocation failed");
 		goto out;
 	}
 
-	memset(str, 0, sz);
-
 	for (i = 0; i < argc; i++) {
 		if (i)
 			strcat(str, " ");


