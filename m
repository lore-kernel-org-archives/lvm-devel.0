From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Sep 2015 12:26:57 +0000 (UTC)
Subject: master - filters: do not print [none:nil] as external device info's [source:handler] if "none" source is used
Message-ID: <20150903122657.A3FBD60D97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00b610e5429582a4a62cdd2d475064dafab6fe87
Commit:        00b610e5429582a4a62cdd2d475064dafab6fe87
Parent:        fc35b6988d65fe3f11a3f668cd8f01fe3294b562
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 3 14:19:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 3 14:19:48 2015 +0200

filters: do not print [none:nil] as external device info's [source:handler] if "none" source is used

Print [source:handler] in filters' debug messages only if external
device info source other than "none" is used.

$ lvmconfig --type full devices/external_device_info_source
external_device_info_source="none

Before this patch (from the -vvvv log):

filters/filter-usable.c:47         /dev/mapper/test: Skipping: Too small to hold a PV [none:(nil)]
filters/filter-md.c:33         /dev/sdb: Skipping md component device [none:(nil)]
filters/filter-partitioned.c:25         /dev/vda: Skipping: Partition table signature found [none:(nil)]

With this patch applied:

filters/filter-usable.c:44         /dev/mapper/test: Skipping: Too small to hold a PV
filters/filter-md.c:35         /dev/sdb: Skipping md component device
filters/filter-partitioned.c:27         /dev/vda: Skipping: Partition table signature found
---
 lib/filters/filter-fwraid.c      |    9 +++++++--
 lib/filters/filter-md.c          |    9 +++++++--
 lib/filters/filter-mpath.c       |    9 +++++++--
 lib/filters/filter-partitioned.c |    9 +++++++--
 lib/filters/filter-usable.c      |   11 ++++-------
 5 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index f16833e..0b3804f 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -61,6 +61,8 @@ static int _dev_is_fwraid(struct device *dev)
 	return 0;
 }
 
+#define MSG_SKIPPING "%s: Skipping firmware RAID component device"
+
 static int _ignore_fwraid(struct dev_filter *f __attribute__((unused)),
 			   struct device *dev)
 {
@@ -72,8 +74,11 @@ static int _ignore_fwraid(struct dev_filter *f __attribute__((unused)),
 	ret = _dev_is_fwraid(dev);
 
 	if (ret == 1) {
-		log_debug_devs("%s: Skipping firmware RAID component device [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		if (dev->ext.src == DEV_EXT_NONE)
+			log_debug_devs(MSG_SKIPPING, dev_name(dev));
+		else
+			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
+					dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index ad9f540..f4e3613 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -18,6 +18,8 @@
 
 #ifdef __linux__
 
+#define MSG_SKIPPING "%s: Skipping md component device"
+
 static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 		      struct device *dev)
 {
@@ -29,8 +31,11 @@ static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 	ret = dev_is_md(dev, NULL);
 
 	if (ret == 1) {
-		log_debug_devs("%s: Skipping md component device [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		if (dev->ext.src == DEV_EXT_NONE)
+			log_debug_devs(MSG_SKIPPING, dev_name(dev));
+		else
+			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
+					dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 0016a51..692e83f 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -244,11 +244,16 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 	return 0;
 }
 
+#define MSG_SKIPPING "%s: Skipping mpath component device"
+
 static int _ignore_mpath(struct dev_filter *f, struct device *dev)
 {
 	if (_dev_is_mpath(f, dev) == 1) {
-		log_debug_devs("%s: Skipping mpath component device [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		if (dev->ext.src == DEV_EXT_NONE)
+			log_debug_devs(MSG_SKIPPING, dev_name(dev));
+		else
+			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
+					dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 9ca8f6f..be0ea99 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -16,13 +16,18 @@
 #include "lib.h"
 #include "filter.h"
 
+#define MSG_SKIPPING "%s: Skipping: Partition table signature found"
+
 static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 
 	if (dev_is_partitioned(dt, dev)) {
-		log_debug_devs("%s: Skipping: Partition table signature found [%s:%p]",
-			       dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		if (dev->ext.src == DEV_EXT_NONE)
+			log_debug_devs(MSG_SKIPPING, dev_name(dev));
+		else
+			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
+					dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index a4cfc69..e39cb54 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -29,22 +29,19 @@ static int _native_check_pv_min_size(struct device *dev)
 
 	/* Check it's accessible */
 	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: Skipping: open failed [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		log_debug_devs("%s: Skipping: open failed", dev_name(dev));
 		return 0;
 	}
 
 	/* Check it's not too small */
 	if (!dev_get_size(dev, &size)) {
-		log_debug_devs("%s: Skipping: dev_get_size failed [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		log_debug_devs("%s: Skipping: dev_get_size failed", dev_name(dev));
 		goto out;
 	}
 
 	if (size < pv_min_size()) {
-		log_debug_devs("%s: Skipping: %s [%s:%p]", dev_name(dev),
-				_too_small_to_hold_pv_msg,
-				dev_ext_name(dev), dev->ext.handle);
+		log_debug_devs("%s: Skipping: %s", dev_name(dev),
+				_too_small_to_hold_pv_msg);
 		goto out;
 	}
 


