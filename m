From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:27:55 -0000
Subject: LVM2/lib activate/activate.c activate/activate ...
Message-ID: <20120119152755.29045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:27:54

Modified files:
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/thin       : thin.c 

Log message:
	Thin add function to read thin volume percent
	
	This value returns percentage of 'mapped' size compared with total LV size.
	(Without passed seg pointer it return highest mapped size - but it's
	not used yet.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.229&r2=1.230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.260&r2=1.261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/lib/activate/activate.c	2012/01/19 15:25:37	1.229
+++ LVM2/lib/activate/activate.c	2012/01/19 15:27:54	1.230
@@ -736,6 +736,32 @@
 	return r;
 }
 
+/*
+ * Returns 1 if percent set, else 0 on failure.
+ */
+int lv_thin_percent(const struct logical_volume *lv,
+		    int mapped, percent_t *percent)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!activation())
+		return 0;
+
+	log_debug("Checking thin percent for LV %s/%s",
+		  lv->vg->name, lv->name);
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_thin_percent(dm, lv, mapped, percent)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct lvinfo info;
--- LVM2/lib/activate/activate.h	2012/01/19 15:25:38	1.92
+++ LVM2/lib/activate/activate.h	2012/01/19 15:27:54	1.93
@@ -103,6 +103,8 @@
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
+int lv_thin_percent(const struct logical_volume *lv, int mapped,
+		    percent_t *percent);
 
 /*
  * Return number of LVs in the VG that are active.
--- LVM2/lib/activate/dev_manager.c	2012/01/19 15:25:38	1.260
+++ LVM2/lib/activate/dev_manager.c	2012/01/19 15:27:54	1.261
@@ -895,6 +895,28 @@
 	return 1;
 }
 
+int dev_manager_thin_percent(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     int mapped, percent_t *percent)
+{
+	char *name;
+	const char *dlid;
+
+	/* Build a name for the top layer */
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+		return_0;
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+		return_0;
+
+	log_debug("Getting device status percentage for %s", name);
+	if (!(_percent(dm, name, dlid, "thin", 0,
+		       (mapped) ? NULL : lv, percent, NULL, 1)))
+		return_0;
+
+	return 1;
+}
+
 /*************************/
 /*  NEW CODE STARTS HERE */
 /*************************/
--- LVM2/lib/activate/dev_manager.h	2012/01/19 15:25:38	1.43
+++ LVM2/lib/activate/dev_manager.h	2012/01/19 15:27:54	1.44
@@ -57,6 +57,9 @@
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
 				  int metadata, percent_t *percent);
+int dev_manager_thin_percent(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     int mapped, percent_t *percent);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
--- LVM2/lib/thin/thin.c	2012/01/19 15:23:51	1.39
+++ LVM2/lib/thin/thin.c	2012/01/19 15:27:54	1.40
@@ -409,6 +409,36 @@
 	return 1;
 }
 
+static int _thin_target_percent(void **target_state __attribute__((unused)),
+				percent_t *percent,
+				struct dm_pool *mem,
+				struct cmd_context *cmd __attribute__((unused)),
+				struct lv_segment *seg,
+				char *params,
+				uint64_t *total_numerator,
+				uint64_t *total_denominator)
+{
+	struct dm_status_thin *s;
+
+	/* Status for thin device is in sectors */
+	if (!dm_get_status_thin(mem, params, &s))
+		return_0;
+
+	if (seg) {
+		*percent = make_percent(s->mapped_sectors, seg->lv->size);
+		*total_denominator += seg->lv->size;
+	} else {
+		/* No lv_segment info here */
+		*percent = PERCENT_INVALID;
+		/* FIXME: Using denominator to pass the mapped info upward? */
+		*total_denominator += s->highest_mapped_sector;
+	}
+
+	*total_numerator += s->mapped_sectors;
+
+	return 1;
+}
+
 static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
 				unsigned *attributes __attribute__((unused)))
@@ -499,6 +529,7 @@
 	.text_export = _thin_text_export,
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _thin_add_target_line,
+	.target_percent = _thin_target_percent,
 	.target_present = _thin_target_present,
 #  ifdef DMEVENTD
 	.target_monitored = _target_registered,


