From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:40:24 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110408144024.11943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:40:21

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c clvmd.c refresh_clvmd.c 
	lib/activate   : fs.c 
	lib/device     : dev-swap.c 
	lib/locking    : cluster_locking.c 
	lib/metadata   : lv_manip.c metadata.c mirror.c 
	lib/misc       : lvm-string.c 
	lib/mm         : memlock.c 
	libdm          : libdm-file.c libdm-report.c 
	libdm/regex    : matcher.c 
	tools          : dmsetup.c lvconvert.c lvmcmdline.c 

Log message:
	Fix some unmatching sign comparation gcc warnings
	
	Simple replacement for unsigned type - usually in for() loops.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1968&r2=1.1969
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-swap.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.256&r2=1.257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.453&r2=1.454
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/WHATS_NEW	2011/04/07 21:49:29	1.1968
+++ LVM2/WHATS_NEW	2011/04/08 14:40:18	1.1969
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix some unmatching sign comparation gcc warnings in the code.
   Allow lv_extend() to work on zero length intrinsically layered LVs.
   Keep the cache content when the exported vg buffer is matching.
   Extend the set of memory regions, that are not locked to memory.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/02/18 16:17:56	1.53
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/04/08 14:40:18	1.54
@@ -377,7 +377,7 @@
 	/* Propogate debug options */
 	if (clvmd_get_debug()) {
 		if (!(debug_arg = malloc(16)) ||
-		    dm_snprintf(debug_arg, 16, "-d%d", (int)clvmd_get_debug()) < 0)
+		    dm_snprintf(debug_arg, 16, "-d%u", clvmd_get_debug()) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
 		debug_arg = NULL;
--- LVM2/daemons/clvmd/clvmd.c	2011/03/30 12:48:16	1.103
+++ LVM2/daemons/clvmd/clvmd.c	2011/04/08 14:40:18	1.104
@@ -2157,7 +2157,7 @@
 {
 	struct local_client *thisfd;
 	for (thisfd = &local_client_head; thisfd != NULL; thisfd = thisfd->next) {
-		if (thisfd->fd == ntohl(clientid))
+		if (thisfd->fd == (int)ntohl(clientid))
 			return thisfd;
 	}
 	return NULL;
--- LVM2/daemons/clvmd/refresh_clvmd.c	2011/03/29 21:05:39	1.14
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2011/04/08 14:40:18	1.15
@@ -80,7 +80,7 @@
 	char outbuf[PIPE_BUF];
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
 	int len;
-	int off;
+	unsigned off;
 	int buflen;
 	int err;
 
--- LVM2/lib/activate/fs.c	2011/02/18 14:16:11	1.61
+++ LVM2/lib/activate/fs.c	2011/04/08 14:40:19	1.62
@@ -327,7 +327,7 @@
 /* Check if there is other the type of fs operation stacked */
 static int _other_fs_ops(fs_op_t type)
 {
-	int i;
+	unsigned i;
 
 	for (i = 0; i < NUM_FS_OPS; i++)
 		if (type != i && _count_fs_ops[i])
--- LVM2/lib/device/dev-swap.c	2010/08/19 23:05:45	1.2
+++ LVM2/lib/device/dev-swap.c	2011/04/08 14:40:19	1.3
@@ -42,7 +42,8 @@
 {
 	char buf[10];
 	uint64_t size;
-	int page, ret = 0;
+	unsigned page;
+	int ret = 0;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
--- LVM2/lib/locking/cluster_locking.c	2011/03/29 21:05:39	1.54
+++ LVM2/lib/locking/cluster_locking.c	2011/04/08 14:40:19	1.55
@@ -100,7 +100,7 @@
 	char outbuf[PIPE_BUF] __attribute__((aligned(8)));
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
 	int len;
-	int off;
+	unsigned off;
 	int buflen;
 	int err;
 
--- LVM2/lib/metadata/lv_manip.c	2011/04/07 21:49:29	1.256
+++ LVM2/lib/metadata/lv_manip.c	2011/04/08 14:40:19	1.257
@@ -976,7 +976,7 @@
 					       (le - seg->le) / area_multiple,
 					       area_len, NULL, max_seg_len, 0,
 					       (stripes_per_mimage == 1) && only_single_area_segments ? 1U : 0U,
-					       top_level_area_index != -1 ? top_level_area_index : (int) s * stripes_per_mimage,
+					       (top_level_area_index != -1) ? top_level_area_index : (int) (s * stripes_per_mimage),
 					       only_single_area_segments, fn,
 					       data)))
 				stack;
--- LVM2/lib/metadata/metadata.c	2011/04/01 14:54:20	1.453
+++ LVM2/lib/metadata/metadata.c	2011/04/08 14:40:20	1.454
@@ -1987,7 +1987,7 @@
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data)
 {
-	int i, s;
+	unsigned i, s;
 	struct lv_segment *lvseg;
 
 	struct logical_volume *deps[] = {
@@ -2111,7 +2111,7 @@
 
 static int _lv_mark_if_partial_single(struct logical_volume *lv, void *data)
 {
-	int s;
+	unsigned s;
 	struct _lv_mark_if_partial_baton baton;
 	struct lv_segment *lvseg;
 
@@ -2200,7 +2200,7 @@
 	struct validate_hash *vhash = data;
 	struct lv_segment *lvseg;
 	struct physical_volume *pv;
-	int s;
+	unsigned s;
 	int r = 1;
 
 	if (lv != dm_hash_lookup_binary(vhash->lvid, &lv->lvid.id[1],
--- LVM2/lib/metadata/mirror.c	2011/04/06 21:32:20	1.147
+++ LVM2/lib/metadata/mirror.c	2011/04/08 14:40:20	1.148
@@ -200,7 +200,7 @@
  */
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage)
 {
-	int i;
+	unsigned i;
 	struct lv_segment_area area;
 
 	if (mimage >= mirrored_seg->area_count) {
@@ -1836,7 +1836,7 @@
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
-	int old_log_count;
+	unsigned old_log_count;
 	int r = 0;
 
 	if (dm_list_size(&lv->segments) != 1) {
--- LVM2/lib/misc/lvm-string.c	2011/03/13 23:18:30	1.26
+++ LVM2/lib/misc/lvm-string.c	2011/04/08 14:40:20	1.27
@@ -144,7 +144,7 @@
  * process several characters in one go.
  */
 static void _unquote_characters(char *src, const char *orig_chars,
-				const int num_orig_chars, 
+				size_t num_orig_chars,
 				const char quote_char,
 				char *arr_substr_first_unquoted[])
 {
--- LVM2/lib/mm/memlock.c	2011/03/30 13:06:13	1.39
+++ LVM2/lib/mm/memlock.c	2011/04/08 14:40:20	1.40
@@ -151,7 +151,8 @@
 {
 	const struct config_value *cv;
 	long from, to;
-	int pos, i;
+	int pos;
+	unsigned i;
 	char fr, fw, fx, fp;
 	size_t sz;
 
--- LVM2/libdm/libdm-file.c	2010/10/20 15:12:12	1.14
+++ LVM2/libdm/libdm-file.c	2011/04/08 14:40:20	1.15
@@ -149,7 +149,7 @@
 		goto fail_close_unlink;
 	}
 
-	if ((write_out == 0) || (write_out < bufferlen)) {
+	if ((write_out == 0) || ((size_t)write_out < bufferlen)) {
 		log_error("Cannot write pid to pidfile [%s], shortwrite of"
 			  "[%" PRIsize_t "] bytes, expected [%" PRIsize_t "]\n",
 			  lockfile, write_out, bufferlen);
--- LVM2/libdm/libdm-report.c	2011/02/18 23:09:55	1.43
+++ LVM2/libdm/libdm-report.c	2011/04/08 14:40:20	1.44
@@ -734,8 +734,8 @@
 			return 0;
 		}
 
-		if ((strlen(field->report_string) > field->props->width))
-			field->props->width = strlen(field->report_string);
+		if (((int) strlen(field->report_string) > field->props->width))
+			field->props->width = (int) strlen(field->report_string);
 
 		if ((rh->flags & RH_SORT_REQUIRED) &&
 		    (field->props->flags & FLD_SORT_KEY)) {
@@ -775,8 +775,8 @@
 	}
 
 	dm_list_iterate_items(fp, &rh->field_props) {
-		if (buf_size < fp->width)
-			buf_size = fp->width;
+		if ((int) buf_size < fp->width)
+			buf_size = (size_t) fp->width;
 	}
 	/* Including trailing '\0'! */
 	buf_size++;
--- LVM2/libdm/regex/matcher.c	2010/12/20 13:23:12	1.16
+++ LVM2/libdm/regex/matcher.c	2011/04/08 14:40:21	1.17
@@ -100,7 +100,7 @@
 
 static void _create_bitsets(struct dm_regex *m)
 {
-	int i;
+	unsigned i;
 
 	for (i = 0; i < m->num_nodes; i++) {
 		struct rx_node *n = m->nodes[i];
@@ -112,7 +112,7 @@
 
 static void _calc_functions(struct dm_regex *m)
 {
-	int i, j, final = 1;
+	unsigned i, j, final = 1;
 	struct rx_node *rx, *c1, *c2;
 
 	for (i = 0; i < m->num_nodes; i++) {
@@ -253,7 +253,8 @@
 {
 	unsigned iwidth = (m->num_charsets / DM_BITS_PER_INT) + 1;
 	struct dfa_state *dfa;
-	int i, a;
+	unsigned i;
+	int a;
 
 	m->tt = ttree_create(m->scratch, iwidth);
 	if (!m->tt)
@@ -314,7 +315,7 @@
 				 unsigned num_patterns)
 {
 	char *all, *ptr;
-	int i;
+	unsigned i;
 	size_t len = 0;
 	struct rx_node *rx;
 	struct dm_regex *m;
--- LVM2/tools/dmsetup.c	2011/03/29 21:56:53	1.158
+++ LVM2/tools/dmsetup.c	2011/04/08 14:40:21	1.159
@@ -2412,7 +2412,7 @@
 			 void *private)
 {
 	const struct dm_deps *deps = data;
-	int i;
+	unsigned i;
 	char buf[DM_MAX_TYPE_NAME], *repstr;
 
 	if (!dm_pool_begin_object(mem, 16)) {
--- LVM2/tools/lvconvert.c	2011/03/29 12:51:58	1.159
+++ LVM2/tools/lvconvert.c	2011/04/08 14:40:21	1.160
@@ -555,7 +555,7 @@
 {
 	struct lv_segment *lvseg;
 	int ret = 0;
-	int s;
+	unsigned s;
 
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (!seg_is_mirrored(lvseg))
--- LVM2/tools/lvmcmdline.c	2011/01/13 15:00:29	1.137
+++ LVM2/tools/lvmcmdline.c	2011/04/08 14:40:21	1.138
@@ -1274,7 +1274,7 @@
 	if (getenv("LVM_SUPPRESS_FD_WARNINGS"))
 		suppress_warnings = 1;
 
-	for (fd = 3; fd < rlim.rlim_cur; fd++)
+	for (fd = 3; fd < (int)rlim.rlim_cur; fd++)
 		_close_descriptor(fd, suppress_warnings, command, ppid,
 				  parent_cmdline);
 }


