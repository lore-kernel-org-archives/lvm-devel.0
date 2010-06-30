From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 12:17:29 -0000
Subject: LVM2 lib/config/defaults.h lib/format_text/for ...
Message-ID: <20100630121729.17914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 12:17:25

Modified files:
	lib/config     : defaults.h 
	lib/format_text: format-text.c format-text.h text_label.c 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : commands.h toollib.c 

Log message:
	Add --metadataignore to pvcreate.
	
	Allow metadataignore flag to be passed in to pvcreate.
	Ideally, more refactoring of the mda allocation / initialization
	is warranted, but for now, we just add another parameter to 'add_mda'
	to take an existing mda ignored flag.  We need to do this or pv_write
	loses the state of the mda 'ignored' flag before copying and writing
	to disk.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.367&r2=1.368
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205

--- LVM2/lib/config/defaults.h	2010/06/28 20:36:37	1.61
+++ LVM2/lib/config/defaults.h	2010/06/30 12:17:24	1.62
@@ -59,6 +59,7 @@
 #define DEFAULT_FORMAT "lvm2"
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
+#define DEFAULT_PVMETADATAIGNORE 0
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_VGMETADATACOPIES 0
--- LVM2/lib/format_text/format-text.c	2010/06/29 22:37:32	1.136
+++ LVM2/lib/format_text/format-text.c	2010/06/30 12:17:24	1.137
@@ -1337,7 +1337,7 @@
 	/* FIXME If creating new mdas, wipe them! */
 	if (mda_size1) {
 		if (!add_mda(fmt, fmt->cmd->mem, mdas, pv->dev, start1,
-			     mda_size1))
+			     mda_size1, 0))
 			return 0;
 
 		if (!dev_set((struct device *) pv->dev, start1,
@@ -1384,7 +1384,7 @@
 
 	if (mda_size2) {
 		if (!add_mda(fmt, fmt->cmd->mem, mdas, pv->dev, start2,
-			     mda_size2)) return 0;
+			     mda_size2, 0)) return 0;
 		if (!dev_set(pv->dev, start2,
 			     (size_t) (mda_size1 >
 				       wipe_size ? : mda_size1), 0)) {
@@ -1440,7 +1440,7 @@
 				  mdac->area.start >> SECTOR_SHIFT,
 				  mdac->area.size >> SECTOR_SHIFT);
 			add_mda(fmt, NULL, &info->mdas, mdac->area.dev,
-				mdac->area.start, mdac->area.size);
+				mdac->area.start, mdac->area.size, mda_is_ignored(mda));
 		}
 		/* FIXME Temporary until mda creation supported by tools */
 	} else if (!info->mdas.n) {
--- LVM2/lib/format_text/format-text.h	2010/06/28 20:31:01	1.27
+++ LVM2/lib/format_text/format-text.h	2010/06/30 12:17:24	1.28
@@ -56,7 +56,7 @@
 void del_das(struct dm_list *das);
 
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
-	    struct device *dev, uint64_t start, uint64_t size);
+	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
 
 #endif
--- LVM2/lib/format_text/text_label.c	2010/06/29 22:25:58	1.33
+++ LVM2/lib/format_text/text_label.c	2010/06/30 12:17:24	1.34
@@ -182,8 +182,9 @@
 	}
 }
 
+/* FIXME: refactor this function with other mda constructor code */
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
-	    struct device *dev, uint64_t start, uint64_t size)
+	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored)
 {
 /* FIXME List size restricted by pv_header SECTOR_SIZE */
 	struct metadata_area *mdal;
@@ -222,6 +223,7 @@
 	mdac->area.size = size;
 	mdac->free_sectors = UINT64_C(0);
 	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
+	mda_set_ignored(mdal, ignored);
 
 	dm_list_add(mdas, &mdal->list);
 	return 1;
@@ -294,7 +296,7 @@
 	dlocn_xl++;
 	while ((offset = xlate64(dlocn_xl->offset))) {
 		add_mda(info->fmt, NULL, &info->mdas, dev, offset,
-			xlate64(dlocn_xl->size));
+			xlate64(dlocn_xl->size), 0);
 		dlocn_xl++;
 	}
 
--- LVM2/lib/metadata/metadata-exported.h	2010/06/29 22:41:28	1.160
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/30 12:17:24	1.161
@@ -453,6 +453,7 @@
 	const char *restorefile; /* 0 if no --restorefile option */
 	force_t force;
 	unsigned yes;
+	unsigned mda_ignore;
 };
 
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2010/06/29 22:41:28	1.367
+++ LVM2/lib/metadata/metadata.c	2010/06/30 12:17:24	1.368
@@ -1580,6 +1580,7 @@
 	pp->restorefile = 0;
 	pp->force = PROMPT;
 	pp->yes = 0;
+	pp->mda_ignore = DEFAULT_PVMETADATAIGNORE;
 }
 
 /*
@@ -1602,6 +1603,7 @@
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute((aligned(8)));
+	struct metadata_area *mda;
 
 	pvcreate_params_set_defaults(&default_pp);
 	if (!pp)
@@ -1667,6 +1669,13 @@
 
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
+
+	if (pp->mda_ignore) {
+		dm_list_iterate_items(mda, &mdas) {
+			mda_set_ignored(mda, 1);
+		}
+	}
+
 	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
--- LVM2/tools/commands.h	2010/06/28 20:39:24	1.150
+++ LVM2/tools/commands.h	2010/06/30 12:17:25	1.151
@@ -517,8 +517,8 @@
 
    dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
    labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG, physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG,
-   yes_ARG, zero_ARG)
+   metadatasize_ARG, metadataignore_ARG, physicalvolumesize_ARG,
+   restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
--- LVM2/tools/toollib.c	2010/06/28 20:38:23	1.204
+++ LVM2/tools/toollib.c	2010/06/30 12:17:25	1.205
@@ -1377,6 +1377,18 @@
 		return 0;
 	}
 
+	if (arg_count(cmd, metadataignore_ARG)) {
+		pp->mda_ignore = !strcmp(arg_str_value(cmd,
+						       metadataignore_ARG,
+						       "n"), "y");
+	}
+	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
+	    pp->mda_ignore) {
+		log_error("metadataignore only applies to metadatacopies > 0");
+		return 0;
+	}
+
 	if (arg_count(cmd, zero_ARG))
 		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 


