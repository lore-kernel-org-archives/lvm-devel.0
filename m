From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Aug 2011 17:40:55 -0000
Subject: LVM2/lib thin/thin.c metadata/metadata-exported.h
Message-ID: <20110826174055.9540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-26 17:40:54

Modified files:
	lib/thin       : thin.c 
	lib/metadata   : metadata-exported.h 

Log message:
	thin - hide unimplemented dso fn; remove duplicate origin_lv field; add
	some lvcreate struct parms

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.202&r2=1.203

--- LVM2/lib/thin/thin.c	2011/08/26 13:37:47	1.3
+++ LVM2/lib/thin/thin.c	2011/08/26 17:40:53	1.4
@@ -107,7 +107,7 @@
                 if (!cn->v || cn->v->type != CFG_STRING)
 			return SEG_LOG_ERROR("Thin pool origin must be a string in");
 
-		if (!(seg->origin_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+		if (!(seg->origin = find_lv(seg->lv->vg, cn->v->v.str)))
 			return SEG_LOG_ERROR("Unknown origin %s in",
 					     cn->v->v.str);
 	}
@@ -123,8 +123,8 @@
 	outf(f, "thin_pool = \"%s\"", seg->thin_pool_lv->name);
 	outf(f, "device_id = %" PRIu64, seg->device_id);
 
-	if (seg->origin_lv)
-		outf(f, "origin = \"%s\"", seg->origin_lv->name);
+	if (seg->origin)
+		outf(f, "origin = \"%s\"", seg->origin->name);
 
 	return 1;
 }
@@ -229,8 +229,8 @@
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-		if (_get_thin_dso_path(cmd))
-			segtype->flags |= SEG_MONITORED;
+// FIXME		if (_get_thin_dso_path(cmd))
+// FIXME			segtype->flags |= SEG_MONITORED;
 #  endif	/* DMEVENTD */
 #endif
 		if (!lvm_register_segtype(seglib, segtype))
--- LVM2/lib/metadata/metadata-exported.h	2011/08/26 13:37:47	1.202
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/26 17:40:53	1.203
@@ -305,7 +305,7 @@
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
-	struct logical_volume *origin;
+	struct logical_volume *origin;	/* snap and thin */
 	struct logical_volume *cow;
 	struct dm_list origin_list;
 	uint32_t region_size;	/* For mirrors, replicators - in sectors */
@@ -323,7 +323,6 @@
 	uint64_t transaction_id;		/* For thin_pool */
 	uint32_t zero_new_blocks;		/* For thin_pool */
 	struct logical_volume *thin_pool_lv;	/* For thin */
-	struct logical_volume *origin_lv;	/* For thin */
 	uint64_t device_id;			/* For thin */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
@@ -547,6 +546,8 @@
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	int thin; /* thin */
+	int create_thin_pool; /* thin */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
@@ -556,6 +557,7 @@
 	activation_change_t activate; /* non-snapshot, non-mirror */
 
 	char *origin; /* snap */
+	char *pool;   /* thin */
 	const char *vg_name; /* all */
 	const char *lv_name; /* all */
 


