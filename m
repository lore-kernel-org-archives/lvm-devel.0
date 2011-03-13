From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Mar 2011 22:52:21 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.c
Message-ID: <20110313225221.11708.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-13 22:52:20

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.c 

Log message:
	Fix usage of readlink
	
	Return value of readlink limits valid string size.
	Characters after returned size present some garbage to printf.
	Fix it by placing '\0' on the return size value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1951&r2=1.1952
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2011/03/11 15:10:16	1.1951
+++ LVM2/WHATS_NEW	2011/03/13 22:52:16	1.1952
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix readlink usage inside get_primary_dev().
   Use format instance mempool where possible and adequate.
   Call destroy_instance for any PVs found in VG structure during vg_free call.
   Add new free_pv_fid fn and use it throughout to free all attached fids.
--- LVM2/lib/device/device.c	2010/12/15 12:49:55	1.36
+++ LVM2/lib/device/device.c	2011/03/13 22:52:20	1.37
@@ -287,7 +287,7 @@
 	struct stat info;
 	FILE *fp;
 	uint32_t pri_maj, pri_min;
-	int ret = 0;
+	int size, ret = 0;
 
 	/* check if dev is a partition */
 	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
@@ -309,11 +309,13 @@
 	 * - basename ../../block/md0/md0  = md0
 	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
 	 */
-	if (readlink(dirname(path), temp_path, PATH_MAX) < 0) {
+	if ((size = readlink(dirname(path), temp_path, PATH_MAX)) < 0) {
 		log_sys_error("readlink", path);
 		return ret;
 	}
 
+	temp_path[size] = '\0';
+
 	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
 			sysfs_dir, basename(dirname(temp_path))) < 0) {
 		log_error("dm_snprintf dev failed");


