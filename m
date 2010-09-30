From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:09:22 -0000
Subject: LVM2/lib/metadata pv.c pv.h
Message-ID: <20100930140922.18362.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:09:22

Modified files:
	lib/metadata   : pv.c pv.h 

Log message:
	Add pv_name_dup() and pv_fmt_dup() helper functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/metadata/pv.c	2010/09/30 14:09:10	1.6
+++ LVM2/lib/metadata/pv.c	2010/09/30 14:09:22	1.7
@@ -21,6 +21,18 @@
  */
 #define pv_field(handle, field)	((handle)->field)
 
+char *pv_fmt_dup(const struct physical_volume *pv)
+{
+	if (!pv->fmt)
+		return NULL;
+	return dm_pool_strdup(pv->vg->vgmem, pv->fmt->name);
+}
+
+char *pv_name_dup(const struct physical_volume *pv)
+{
+	return dm_pool_strdup(pv->vg->vgmem, dev_name(pv->dev));
+}
+
 /*
  * Gets/Sets for external LVM library
  */
--- LVM2/lib/metadata/pv.h	2010/09/30 14:09:10	1.5
+++ LVM2/lib/metadata/pv.h	2010/09/30 14:09:22	1.6
@@ -52,6 +52,8 @@
 	struct dm_list tags;
 };
 
+char *pv_fmt_dup(const struct physical_volume *pv);
+char *pv_name_dup(const struct physical_volume *pv);
 struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);


