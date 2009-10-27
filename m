From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Oct 2009 17:00:47 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/filt ...
Message-ID: <20091027170047.18917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-10-27 17:00:47

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/filters    : filter.c filter.h 
	lib/format1    : disk-rep.c 
	lib/format_pool: disk_rep.c 

Log message:
	Recognise DRBD device part and handle it similar to MD devices.
	
	The DRBD uses underlying device so code should prefer top
	device if duplicate is found.
	
	Patch also introduce
	dev_subsystem_part_major and dev_subsytem_name
	functions to easily handle all these replication susbystems
	and not hardcode md_major call.
	
	See https://bugzilla.redhat.com/show_bug.cgi?id=530881
	for full problem description.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1307&r2=1.1308
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2009/10/27 01:13:21	1.1307
+++ LVM2/WHATS_NEW	2009/10/27 17:00:44	1.1308
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Recognise DRBD device part and handle it similar to MD devices.
 
 Version 2.02.54 - 26th October 2009
 ===================================
--- LVM2/lib/cache/lvmcache.c	2009/10/22 17:33:09	1.70
+++ LVM2/lib/cache/lvmcache.c	2009/10/27 17:00:46	1.71
@@ -1173,11 +1173,12 @@
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
-			if (MAJOR(existing->dev->dev) == md_major() &&
-			    MAJOR(dev->dev) != md_major()) {
+			if (dev_subsystem_part_major(existing->dev) &&
+			    !dev_subsystem_part_major(dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s - using md %s",
+						 "%s - using %s %s",
 						 pvid, dev_name(dev),
+						 dev_subsystem_name(existing->dev),
 						 dev_name(existing->dev));
 				return NULL;
 			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
@@ -1187,11 +1188,12 @@
 						 pvid, dev_name(dev),
 						 dev_name(existing->dev));
 				return NULL;
-			} else if (MAJOR(existing->dev->dev) != md_major() &&
-				   MAJOR(dev->dev) == md_major())
+			} else if (!dev_subsystem_part_major(existing->dev) &&
+				   dev_subsystem_part_major(dev))
 				log_very_verbose("Duplicate PV %s on %s - "
-						 "using md %s", pvid,
+						 "using %s %s", pvid,
 						 dev_name(existing->dev),
+						 dev_subsystem_name(existing->dev),
 						 dev_name(dev));
 			else if (!dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 dm_is_dm_major(MAJOR(dev->dev)))
--- LVM2/lib/filters/filter.c	2009/08/19 15:34:46	1.49
+++ LVM2/lib/filters/filter.c	2009/10/27 17:00:46	1.50
@@ -39,6 +39,7 @@
 
 static int _md_major = -1;
 static int _blkext_major = -1;
+static int _drbd_major = -1;
 static int _device_mapper_major = -1;
 
 int md_major(void)
@@ -51,6 +52,31 @@
 	return _blkext_major;
 }
 
+int dev_subsystem_part_major(const struct device *dev)
+{
+	if (MAJOR(dev->dev) == -1)
+		return 0;
+
+	if (MAJOR(dev->dev) == _md_major)
+		return 1;
+
+	if (MAJOR(dev->dev) == _drbd_major)
+		return 1;
+
+	return 0;
+}
+
+const char *dev_subsystem_name(const struct device *dev)
+{
+	if (MAJOR(dev->dev) == _md_major)
+		return "MD";
+
+	if (MAJOR(dev->dev) == _drbd_major)
+		return "DRBD";
+
+	return "";
+}
+
 /*
  * Devices are only checked for partition tables if their minor number
  * is a multiple of the number corresponding to their type below
@@ -207,6 +233,10 @@
 		if (!strncmp("blkext", line + i, 6) && isspace(*(line + i + 6)))
 			_blkext_major = line_maj;
 
+		/* Look for drbd device */
+		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
+			_drbd_major = line_maj;
+
 		/* Look for device-mapper device */
 		/* FIXME Cope with multiple majors */
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
--- LVM2/lib/filters/filter.h	2009/08/19 15:34:46	1.16
+++ LVM2/lib/filters/filter.h	2009/10/27 17:00:46	1.17
@@ -39,4 +39,7 @@
 int blkext_major(void);
 int max_partitions(int major);
 
+int dev_subsystem_part_major(const struct device *dev);
+const char *dev_subsystem_name(const struct device *dev);
+
 #endif
--- LVM2/lib/format1/disk-rep.c	2009/07/15 20:02:46	1.79
+++ LVM2/lib/format1/disk-rep.c	2009/10/27 17:00:46	1.80
@@ -435,14 +435,15 @@
 		pvd = &diskl->pvd;
 		if (!strncmp((char *)data->pvd.pv_uuid, (char *)pvd->pv_uuid,
 			     sizeof(pvd->pv_uuid))) {
-			if (MAJOR(data->dev->dev) != md_major()) {
+			if (!dev_subsystem_part_major(data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", pvd->pv_uuid,
 						 dev_name(data->dev));
 				return;
 			}
-			log_very_verbose("Duplicate PV %s - using md %s",
-					 pvd->pv_uuid, dev_name(data->dev));
+			log_very_verbose("Duplicate PV %s - using %s %s",
+					 pvd->pv_uuid, dev_subsystem_name(data->dev),
+					 dev_name(data->dev));
 			dm_list_del(&diskl->list);
 			break;
 		}
--- LVM2/lib/format_pool/disk_rep.c	2008/11/04 15:07:44	1.15
+++ LVM2/lib/format_pool/disk_rep.c	2009/10/27 17:00:46	1.16
@@ -62,14 +62,15 @@
 
 			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
 
-			if (MAJOR(data->dev->dev) != md_major()) {
+			if (!dev_subsystem_part_major(data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", uuid,
 						 dev_name(data->dev));
 				return;
 			}
-			log_very_verbose("Duplicate PV %s - using md %s",
-					 uuid, dev_name(data->dev));
+			log_very_verbose("Duplicate PV %s - using %s %s",
+					 uuid, dev_subsystem_name(data->dev),
+					 dev_name(data->dev));
 			dm_list_del(&pl->list);
 			break;
 		}


