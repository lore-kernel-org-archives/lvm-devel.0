From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Jan 2015 17:57:48 +0000 (UTC)
Subject: master - toollib: override the PV device with duplicates
Message-ID: <20150114175748.ED8486110C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57d74a45a05ef14655fbb575586738b6a4cfd4da
Commit:        57d74a45a05ef14655fbb575586738b6a4cfd4da
Parent:        c1f246fedfc349c25749da501e68a7f70bd122b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 13 16:16:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 14 11:57:29 2015 -0600

toollib: override the PV device with duplicates

When multiple duplicate devices are specified on the
command line, the PV is processed once for each of them,
but pv->dev is the device used each time.

This overrides the PV device to reflect the duplicate
device that was specified on the command line.  This is
done by hacking the lvmcache to replace pv->dev with the
device of the duplicate being processed.  (It would be
preferable to override pv->dev without munging the content
of the cache, and without sprinkling special cases throughout
the code.)

This override only applies when multiple duplicate devices are
specified on the command line.  When only a single duplicate
device of pv->dev is specified, the priority is to display the
cached pv->dev, so pv->dev is not overridden by the named
duplicate device.

In the examples below, loop3 is the cached device referenced
by pv->dev, and is given priority for processing.  Only after
loop3 is processed/displayed, will other duplicate devices
loop0/loop1 appear (when requested on the command line.)

With two duplicate devices, loop0 and loop3:

  # pvs
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop0
  PV         VG           Fmt  Attr PSize   PFree
  /dev/loop3 loopa        lvm2 a--   12.00m  12.00m

  # pvs /dev/loop3
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop0
  PV         VG    Fmt  Attr PSize  PFree
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m

  # pvs /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop0
  PV         VG    Fmt  Attr PSize  PFree
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m

  # pvs -o+dev_size /dev/loop0 /dev/loop3
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop0
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop0 loopa lvm2 a--  12.00m 12.00m  16.00m
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

With three duplicate devices, loop0, loop1, loop3:

  # pvs -o+dev_size
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG           Fmt  Attr PSize   PFree   DevSize
  /dev/loop3 loopa        lvm2 a--   12.00m  12.00m  32.00m

  # pvs -o+dev_size /dev/loop3
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop1
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop3 /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop0 loopa lvm2 a--  12.00m 12.00m  16.00m
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop3 /dev/loop1
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop1 loopa lvm2 a--  12.00m 12.00m  32.00m
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop0 /dev/loop1
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop1 loopa lvm2 a--  12.00m 12.00m  32.00m
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m

  # pvs -o+dev_size /dev/loop0 /dev/loop1 /dev/loop3
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop1 not /dev/loop0
  Found duplicate PV XhLbpVo0hmuwrMQLjfxuAvPFUFZqD4vr: using /dev/loop3 not /dev/loop1
  PV         VG    Fmt  Attr PSize  PFree  DevSize
  /dev/loop0 loopa lvm2 a--  12.00m 12.00m  16.00m
  /dev/loop1 loopa lvm2 a--  12.00m 12.00m  32.00m
  /dev/loop3 loopa lvm2 a--  12.00m 12.00m  32.00m
---
 lib/cache/lvmcache.c |   21 +++++++++++++++++++++
 lib/cache/lvmcache.h |    3 +++
 tools/toollib.c      |   15 +++++++++++----
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 932b1ca..6cdf766 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1467,6 +1467,27 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 	return 1;
 }
 
+/*
+ * Replace pv->dev with dev so that dev will appear for reporting.
+ */
+
+void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
+			  struct device *dev)
+{
+	struct lvmcache_info *info;
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+
+	strncpy(pvid_s, (char *) &pv->id, sizeof(pvid_s) - 1);
+	pvid_s[sizeof(pvid_s) - 1] = '\0';
+
+	if (!(info = lvmcache_info_from_pvid(pvid_s, 0)))
+		return;
+
+	info->dev = dev;
+	info->label->dev = dev;
+	pv->dev = dev;
+}
+
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   struct device *dev,
 				   const char *vgname, const char *vgid,
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d43866d..7a04917 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -157,4 +157,7 @@ unsigned lvmcache_mda_count(struct lvmcache_info *info);
 int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
+void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
+			struct device *dev);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index c534e89..472e362 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2221,6 +2221,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct device_id_list *dil;
+	struct device *dev_orig;
 	const char *pv_name;
 	int process_pv;
 	int dev_found;
@@ -2298,11 +2299,14 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 					_device_list_remove(arg_devices, dil->dev);
 
 					/*
-					 * This will simply display the same PV
-					 * multiple times.  Further changes would
-					 * be needed to make this display the details
-					 * of dil->dev instead of pv->dev.
+					 * Replace pv->dev with this dil->dev
+					 * in lvmcache so the duplicate dev
+					 * info will be reported.  FIXME: it
+					 * would be nicer to override pv->dev
+					 * without munging lvmcache content.
 					 */
+					dev_orig = pv->dev;
+					lvmcache_replace_dev(cmd, pv, dil->dev);
 
 					log_very_verbose("Processing PV %s device %s in VG %s.",
 							 pv_name, dev_name(dil->dev), vg->name);
@@ -2312,6 +2316,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 						stack;
 					if (ret > ret_max)
 						ret_max = ret;
+
+					/* Put the cache state back as it was. */
+					lvmcache_replace_dev(cmd, pv, dev_orig);
 				}
 			}
 		}


