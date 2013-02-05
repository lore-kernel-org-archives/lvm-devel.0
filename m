From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 5 Feb 2013 13:05:29 -0500 (EST)
Subject: [PATCH] lvm: don't set snapshot cow device read only
Message-ID: <Pine.LNX.4.64.1302051301580.19904@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

This is the patch for the bug in lvm that it creates read-only 
snapshot-cow device and then lets the kernel driver to write to the 
device.

BTW. I'd like to ask - what does this "vg->status & LVM_WRITE" flag mean 
and how is it controlled? It is supposed to mean that the volume group is 
read-only or read-write, but I don't know how is it set (there is no 
read-only flag in vgchange or vgconvert) and what exactly does it cause.

Mikulas

---

lvm: don't set snapshot cow device read only

lvm has a bug: when creating snapshot with "--permission r", the
underlying -cow device is set read-only. Kernel than tries to write to
this read-only device when creating metadata header and when processing
writes to the origin. The kernel doesn't check writes to read-only
device originating from kernelspace, thus this bug becomes unnoticed.
However, if we modify the kernel to not allow write bios to read-only
devices, this bug shows up.

This patch fixes lvm so that the underlying -cow device is always
read-write.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |    9 ++++++---
 lib/activate/dev_manager.h |    3 ++-
 3 files changed, 9 insertions(+), 5 deletions(-)

Index: LVM2.2.02.98/lib/activate/dev_manager.c
===================================================================
--- LVM2.2.02.98.orig/lib/activate/dev_manager.c	2013-02-04 19:53:38.000000000 +0100
+++ LVM2.2.02.98/lib/activate/dev_manager.c	2013-02-05 16:01:58.000000000 +0100
@@ -61,9 +61,12 @@ struct lv_layer {
 
 static const char _thin_layer[] = "tpool";
 
-int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
+int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts,
+		 const char *layer)
 {
-	return (laopts->read_only || !(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
+	if (!(lv->vg->status & LVM_WRITE)) return 1;
+	if (layer && !strcmp(layer, "cow")) return 0;
+	return laopts->read_only || !(lv->status & LVM_WRITE);
 }
 
 /*
@@ -1968,7 +1971,7 @@ static int _add_new_lv_to_dtree(struct d
 	if (!(dnode = dm_tree_add_new_dev_with_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
-					     read_only_lv(lv, laopts),
+					     read_only_lv(lv, laopts, layer),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
 					     _get_udev_flags(dm, lv, layer))))
Index: LVM2.2.02.98/lib/activate/activate.c
===================================================================
--- LVM2.2.02.98.orig/lib/activate/activate.c	2013-02-05 01:14:34.000000000 +0100
+++ LVM2.2.02.98/lib/activate/activate.c	2013-02-05 01:15:06.000000000 +0100
@@ -1857,7 +1857,7 @@ static int _lv_activate(struct cmd_conte
 	 * Nothing to do?
 	 */
 	if (info.exists && !info.suspended && info.live_table &&
-	    (info.read_only == read_only_lv(lv, laopts))) {
+	    (info.read_only == read_only_lv(lv, laopts, NULL))) {
 		r = 1;
 		goto out;
 	}
Index: LVM2.2.02.98/lib/activate/dev_manager.h
===================================================================
--- LVM2.2.02.98.orig/lib/activate/dev_manager.h	2013-02-05 01:14:20.000000000 +0100
+++ LVM2.2.02.98/lib/activate/dev_manager.h	2013-02-05 01:14:29.000000000 +0100
@@ -26,7 +26,8 @@ struct dev_manager;
 struct dm_info;
 struct device;
 
-int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts);
+int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts,
+		 const char *layer);
 
 /*
  * Constructor and destructor.


