From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Mar 2009 13:59:58 -0000
Subject: LVM2 ./WHATS_NEW lib/Makefile.in lib/device/de ...
Message-ID: <20090317135958.24312.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-03-17 13:59:57

Modified files:
	.              : WHATS_NEW 
	lib            : Makefile.in 
	lib/device     : device.h 
	test           : t-pvcreate-operation.sh 
	tools          : pvcreate.c 

Log message:
	Detect and wipe swap signatures in pvcreate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1066&r2=1.1067
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2009/03/16 14:34:57	1.1066
+++ LVM2/WHATS_NEW	2009/03/17 13:59:56	1.1067
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Detect and conditionally wipe swapspace signatures in pvcreate.
   Fix maximal volume count check for snapshots if max_lv set for volume group.
   Fix lvcreate to remove cow volume if the snapshot creation fails.
   Fix error messages when PV uuid or pe_start reading fails.
--- LVM2/lib/Makefile.in	2009/03/06 16:19:53	1.90
+++ LVM2/lib/Makefile.in	2009/03/17 13:59:56	1.91
@@ -42,6 +42,7 @@
 	device/dev-cache.c \
 	device/dev-io.c \
 	device/dev-md.c \
+	device/dev-swap.c \
 	device/device.c \
 	display/display.c \
 	error/errseg.c \
--- LVM2/lib/device/device.h	2008/11/03 22:14:27	1.37
+++ LVM2/lib/device/device.h	2009/03/17 13:59:56	1.38
@@ -93,6 +93,7 @@
 
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
+int dev_is_swap(struct device *dev, uint64_t *signature);
 unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
--- LVM2/test/t-pvcreate-operation.sh	2008/12/16 20:02:52	1.14
+++ LVM2/test/t-pvcreate-operation.sh	2009/03/17 13:59:56	1.15
@@ -108,3 +108,10 @@
 pvcreate --uuid $uuid1 $dev1
 vgcfgbackup -f $backupfile
 not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
+
+# pvcreate wipes swap signature when forced
+dd if=/dev/zero of=$dev1 bs=1024 count=64
+mkswap $dev1
+file -s $dev1 | grep "swap file"
+pvcreate -f $dev1
+file -s $dev1 | not grep "swap file"
--- LVM2/tools/pvcreate.c	2009/02/25 23:29:07	1.78
+++ LVM2/tools/pvcreate.c	2009/03/17 13:59:57	1.79
@@ -45,7 +45,7 @@
 {
 	struct physical_volume *pv;
 	struct device *dev;
-	uint64_t md_superblock;
+	uint64_t md_superblock, swap_signature;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -129,6 +129,17 @@
 		}
 	}
 
+	if (dev_is_swap(dev, &swap_signature) &&
+	    ((!pp->idp && !pp->restorefile) || pp->yes ||
+	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
+			    name) == 'y'))) {
+		log_print("Wiping swap signature on %s", name);
+		if (!dev_set(dev, swap_signature, 10, 0)) {
+			log_error("Failed to wipe swap signature on %s", name);
+			return 0;
+		}
+	}
+
 	if (sigint_caught())
 		return 0;
 


