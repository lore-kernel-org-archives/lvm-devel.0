From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:22 -0400
Subject: [RFC PATCH 3/7] separate metadata parse and verification
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F39A.6040302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch separates parse and verification process in _reav_pv function.
Instead of getting device data by accessing and checking devices, the
DEV_NEED_VERIFY flag is set to the device structures so that they will
be verified later.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/cache/lvmcache.c          |    5 +++--
 lib/device/dev-cache.c        |   12 ++++++++++++
 lib/device/dev-cache.h        |    1 +
 lib/device/device.h           |    2 ++
 lib/format_text/format-text.c |   37 ++++++++++++++++++++++++++++++++-----
 lib/format_text/format-text.h |    2 ++
 lib/format_text/import_vsn1.c |   40 ++++++++++++++++++++++++++++------------
 lib/label/label.c             |    9 +++++++++
 8 files changed, 89 insertions(+), 19 deletions(-)

Index: LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/cache/lvmcache.c
+++ LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
@@ -525,6 +525,8 @@ struct volume_group *lvmcache_get_vg(con
 		return_NULL;
 	}
 
+	verify_pv_status(fid, vg);
+
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
@@ -705,7 +707,6 @@ static int _drop_vginfo(struct lvmcache_
 	return 1;
 }
 
-/* Unused
 void lvmcache_del(struct lvmcache_info *info)
 {
 	if (info->dev->pvid[0] && _pvid_hash)
@@ -718,7 +719,7 @@ void lvmcache_del(struct lvmcache_info *
 	dm_free(info);
 
 	return;
-} */
+}
 
 static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
Index: LVM2.02.46-cvs-20090324/lib/device/dev-cache.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/device/dev-cache.c
+++ LVM2.02.46-cvs-20090324/lib/device/dev-cache.c
@@ -779,3 +779,15 @@ const char *dev_name(const struct device
 	return (dev) ? dm_list_item(dev->aliases.n, struct str_list)->str :
 	    "unknown device";
 }
+
+int dev_is_valid(struct device *dev, struct dev_filter *f)
+{
+	if (dev->flags & DEV_NEED_VERIFY) {
+		dev->flags &= ~DEV_NEED_VERIFY;
+
+		if (!f->passes_filter(f, dev))
+			return 0;
+	}
+
+	return 1;
+}
Index: LVM2.02.46-cvs-20090324/lib/device/dev-cache.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/device/dev-cache.h
+++ LVM2.02.46-cvs-20090324/lib/device/dev-cache.h
@@ -51,5 +51,6 @@ struct dev_iter;
 struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan);
 void dev_iter_destroy(struct dev_iter *iter);
 struct device *dev_iter_get(struct dev_iter *iter);
+int dev_is_valid(struct device *dev, struct dev_filter *f);
 
 #endif
Index: LVM2.02.46-cvs-20090324/lib/device/device.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/device/device.h
+++ LVM2.02.46-cvs-20090324/lib/device/device.h
@@ -28,6 +28,8 @@
 #define DEV_O_DIRECT		0x00000020	/* Use O_DIRECT */
 #define DEV_O_DIRECT_TESTED	0x00000040	/* DEV_O_DIRECT is reliable */
 
+#define DEV_NEED_VERIFY		0x10000000	/* Should be verified */
+
 /*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
Index: LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/format-text.c
+++ LVM2.02.46-cvs-20090324/lib/format_text/format-text.c
@@ -439,6 +439,27 @@ static int _raw_holds_vgname(struct form
 	return r;
 }
 
+void verify_pv_status(struct format_instance *fid, struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	char buffer[64] __attribute((aligned(8)));
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!dev_is_valid(pvl->pv->dev, vg->cmd->filter) ||
+		    !(pvl->pv->dev = device_from_pvid(fid->fmt->cmd,
+						      &pvl->pv->id))) {
+			if (!id_write_format(&pvl->pv->id, buffer,
+					     sizeof(buffer)))
+				log_error("Couldn't find device.");
+			else
+				log_error("Couldn't find device with uuid"
+					  " '%s'.", buffer);
+
+			pvl->pv->status |= MISSING_PV;
+		}
+	}
+}
+
 static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      const char *vgname,
 					      struct device_area *area,
@@ -487,6 +508,8 @@ static struct volume_group *_vg_read_raw
 	if (precommitted)
 		vg->status |= PRECOMMITTED;
 
+	verify_pv_status(fid, vg);
+
       out:
 	if (!dev_close(area->dev))
 		stack;
@@ -783,7 +806,8 @@ static int _vg_remove_raw(struct format_
 
 static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 					       const char *vgname,
-					       const char *read_path)
+					       const char *read_path,
+					       int verify_pv)
 {
 	struct volume_group *vg;
 	time_t when;
@@ -805,6 +829,9 @@ static struct volume_group *_vg_read_fil
 	} else
 		log_debug("Read volume group %s from %s", vg->name, read_path);
 
+	if (verify_pv)
+		verify_pv_status(fid, vg);
+
 	return vg;
 }
 
@@ -814,7 +841,7 @@ static struct volume_group *_vg_read_fil
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
-	return _vg_read_file_name(fid, vgname, tc->path_live);
+	return _vg_read_file_name(fid, vgname, tc->path_live, 1);
 }
 
 static struct volume_group *_vg_read_precommit_file(struct format_instance *fid,
@@ -824,10 +851,10 @@ static struct volume_group *_vg_read_pre
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	if ((vg = _vg_read_file_name(fid, vgname, tc->path_edit)))
+	if ((vg = _vg_read_file_name(fid, vgname, tc->path_edit, 1)))
 		vg->status |= PRECOMMITTED;
 	else
-		vg = _vg_read_file_name(fid, vgname, tc->path_live);
+		vg = _vg_read_file_name(fid, vgname, tc->path_live, 1);
 
 	return vg;
 }
@@ -1023,7 +1050,7 @@ static int _scan_file(const struct forma
 				fid = _text_create_text_instance(fmt, NULL, NULL,
 							    NULL);
 				if ((vg = _vg_read_file_name(fid, vgname,
-							     path)))
+							     path, 1)))
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
 			}
Index: LVM2.02.46-cvs-20090324/lib/format_text/format-text.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/format-text.h
+++ LVM2.02.46-cvs-20090324/lib/format_text/format-text.h
@@ -47,6 +47,8 @@ struct format_type *create_text_format(s
 void *create_text_context(struct cmd_context *cmd, const char *path,
 			  const char *desc);
 
+void verify_pv_status(struct format_instance *fid, struct volume_group *vg);
+
 struct labeller *text_labeller_create(const struct format_type *fmt);
 
 int pvhdr_read(struct device *dev, char *buf);
Index: LVM2.02.46-cvs-20090324/lib/format_text/import_vsn1.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/format_text/import_vsn1.c
+++ LVM2.02.46-cvs-20090324/lib/format_text/import_vsn1.c
@@ -150,6 +150,32 @@ static int _read_flag_config(struct conf
 	return 1;
 }
 
+static int _read_device(struct cmd_context *cmd, struct device **dev,
+			struct config_node *cn,	const char *path)
+{
+	struct config_value *cv;
+
+	if (!(cn = find_config_node(cn, path))) {
+		log_error("Couldn't find device.");
+		return 0;
+	}
+
+	cv = cn->v;
+	if (!cv || cv->type != CFG_STRING || !cv->v.str) {
+		log_error("device must be a string.");
+		return 0;
+	}
+
+	/* dev_cache_get function causes disk access if partition
+	   information is not cached on memory */
+	if (!(*dev = dev_cache_get(cv->v.str, NULL)))
+		return 0;
+
+	(*dev)->flags |= DEV_NEED_VERIFY;
+
+	return 1;
+}
+
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
 		    struct config_node *vgn __attribute((unused)),
@@ -183,18 +209,8 @@ static int _read_pv(struct format_instan
 		return 0;
 	}
 
-	/*
-	 * Convert the uuid into a device.
-	 */
-	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id))) {
-		char buffer[64] __attribute((aligned(8)));
-
-		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			log_error("Couldn't find device.");
-		else
-			log_error("Couldn't find device with uuid '%s'.",
-				  buffer);
-	}
+	if (!_read_device(fid->fmt->cmd, &pv->dev, pvn, "device"))
+		log_error("Couldn't get device for physical volume.");
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
 		return_0;
Index: LVM2.02.46-cvs-20090324/lib/label/label.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/label/label.c
+++ LVM2.02.46-cvs-20090324/lib/label/label.c
@@ -19,6 +19,8 @@
 #include "xlate.h"
 #include "lvmcache.h"
 #include "metadata.h"
+#include "toolcontext.h"
+#include "dev-cache.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -283,6 +285,13 @@ int label_read(struct device *dev, struc
 		return r;
 	}
 
+	if ((info = info_from_pvid(dev->pvid, 0))) {
+		if (!dev_is_valid(info->dev, info->fmt->cmd->filter)) {
+			lvmcache_del(info);
+			goto out;
+		}
+	}
+
 	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
 		goto out;
 






