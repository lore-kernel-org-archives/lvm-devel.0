From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:16:22 -0000
Subject: LVM2 ./WHATS_NEW libdm/ioctl/libdm-iface.c
Message-ID: <20100803131622.11846.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:16:21

Modified files:
	.              : WHATS_NEW 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix 'void*' arithmetic warning in some functions from libdm-iface.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1691&r2=1.1692
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2010/08/03 13:13:01	1.1691
+++ LVM2/WHATS_NEW	2010/08/03 13:16:21	1.1692
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix 'void*' arithmetic warning in some functions from libdm-iface.c.
   Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().
   Fix const warning in archive_file structure from archive.c.
   Clean generated files .exported_symbols_generated, example.conf for distclean.
--- LVM2/libdm/ioctl/libdm-iface.c	2010/08/03 13:06:36	1.78
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/08/03 13:16:21	1.79
@@ -1104,7 +1104,7 @@
 		return _dm_task_get_deps_v1(dmt);
 #endif
 
-	return (struct dm_deps *) (((void *) dmt->dmi.v4) +
+	return (struct dm_deps *) (((char *) dmt->dmi.v4) +
 				   dmt->dmi.v4->data_start);
 }
 
@@ -1115,13 +1115,13 @@
 		return _dm_task_get_names_v1(dmt);
 #endif
 
-	return (struct dm_names *) (((void *) dmt->dmi.v4) +
+	return (struct dm_names *) (((char *) dmt->dmi.v4) +
 				    dmt->dmi.v4->data_start);
 }
 
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt)
 {
-	return (struct dm_versions *) (((void *) dmt->dmi.v4) +
+	return (struct dm_versions *) (((char *) dmt->dmi.v4) +
 				       dmt->dmi.v4->data_start);
 }
 


