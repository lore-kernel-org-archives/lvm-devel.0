From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:21:25 -0000
Subject: LVM2 daemons/dmeventd/plugins/thin/dmeventd_th ...
Message-ID: <20120119152125.25519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:21:24

Modified files:
	daemons/dmeventd/plugins/thin: dmeventd_thin.c 
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Thin use consistentely metadata
	
	Do not shortcut to 'meta' and stay with 'metadata'
	Also matches kernel doc for dm API then.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2011/12/22 15:57:29	1.2
+++ LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2012/01/19 15:21:23	1.3
@@ -38,9 +38,9 @@
 
 struct dso_state {
 	struct dm_pool *mem;
-	int meta_percent_check;
+	int metadata_percent_check;
 	int data_percent_check;
-	uint64_t known_meta_size;
+	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	char cmd_str[1024];
 };
@@ -183,9 +183,9 @@
 #endif
 
 	/* Thin pool size had changed. Clear the threshold. */
-	if (state->known_meta_size != tps->total_meta_blocks) {
-		state->meta_percent_check = CHECK_MINIMUM;
-		state->known_meta_size = tps->total_meta_blocks;
+	if (state->known_metadata_size != tps->total_metadata_blocks) {
+		state->metadata_percent_check = CHECK_MINIMUM;
+		state->known_metadata_size = tps->total_metadata_blocks;
 	}
 
 	if (state->known_data_size != tps->total_data_blocks) {
@@ -193,13 +193,13 @@
 		state->known_data_size = tps->total_data_blocks;
 	}
 
-	percent = 100 * tps->used_meta_blocks / tps->total_meta_blocks;
-	if (percent >= state->meta_percent_check) {
+	percent = 100 * tps->used_metadata_blocks / tps->total_metadata_blocks;
+	if (percent >= state->metadata_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since the last
 		 * time. Run actions.
 		 */
-		state->meta_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+		state->metadata_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		/* FIXME: extension of metadata needs to be written! */
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
@@ -259,7 +259,7 @@
 	}
 
 	state->mem = statemem;
-	state->meta_percent_check = CHECK_MINIMUM;
+	state->metadata_percent_check = CHECK_MINIMUM;
 	state->data_percent_check = CHECK_MINIMUM;
 	*private = state;
 
--- LVM2/lib/thin/thin.c	2011/12/21 13:08:13	1.37
+++ LVM2/lib/thin/thin.c	2012/01/19 15:21:23	1.38
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -303,31 +303,28 @@
 				     percent_t *percent,
 				     struct dm_pool *mem,
 				     struct cmd_context *cmd __attribute__((unused)),
-				     struct lv_segment *seg __attribute__((unused)),
+				     struct lv_segment *seg,
 				     char *params,
 				     uint64_t *total_numerator,
 				     uint64_t *total_denominator)
 {
 	struct dm_status_thin_pool *s;
-	percent_t meta_percent;
-	percent_t data_percent;
 
 	if (!dm_get_status_thin_pool(mem, params, &s))
 		return_0;
 
-	/*
-	 * FIXME: how to handle exhaust of metadata space
-	 * pick the max from data and meta?
-	 * Support for metadata resize is needed.
-	 */
-	meta_percent = make_percent(s->used_meta_blocks,
-				    s->total_meta_blocks);
-	data_percent = make_percent(s->used_data_blocks,
-				    s->total_data_blocks);
-
-	*percent = data_percent;
-	*total_numerator += s->used_data_blocks;
-	*total_denominator += s->total_data_blocks;
+        /* With seg report metadata percent, otherwice data percent */
+	if (seg) {
+		*percent = make_percent(s->used_metadata_blocks,
+					s->total_metadata_blocks);
+		*total_numerator += s->used_metadata_blocks;
+		*total_denominator += s->total_metadata_blocks;
+	} else {
+		*percent = make_percent(s->used_data_blocks,
+					s->total_data_blocks);
+		*total_numerator += s->used_data_blocks;
+		*total_denominator += s->total_data_blocks;
+	}
 
 	return 1;
 }
--- LVM2/libdm/libdevmapper.h	2012/01/11 12:34:45	1.175
+++ LVM2/libdm/libdevmapper.h	2012/01/19 15:21:23	1.176
@@ -243,10 +243,11 @@
 
 struct dm_status_thin_pool {
 	uint64_t transaction_id;
-	uint64_t used_meta_blocks;
-	uint64_t total_meta_blocks;
+	uint64_t used_metadata_blocks;
+	uint64_t total_metadata_blocks;
 	uint64_t used_data_blocks;
 	uint64_t total_data_blocks;
+	uint64_t held_metadata_root;
 };
 
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
--- LVM2/libdm/libdm-deptree.c	2012/01/10 02:03:32	1.148
+++ LVM2/libdm/libdm-deptree.c	2012/01/19 15:21:23	1.149
@@ -3117,10 +3117,11 @@
 		return 0;
 	}
 
+	/* FIXME: add support for held metadata root */
 	if (sscanf(params, "%" PRIu64 " %" PRIu64 "/%" PRIu64 " %" PRIu64 "/%" PRIu64,
 		   &s->transaction_id,
-		   &s->used_meta_blocks,
-		   &s->total_meta_blocks,
+		   &s->used_metadata_blocks,
+		   &s->total_metadata_blocks,
 		   &s->used_data_blocks,
 		   &s->total_data_blocks) != 5) {
 		log_error("Failed to parse thin pool params: %s.", params);


