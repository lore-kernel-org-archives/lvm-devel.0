From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Mar 2009 14:01:02 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20090317140102.27121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-03-17 14:01:01

Modified files:
	tools          : pvcreate.c 

Log message:
	Some extra (paranoid) checks on dev_is_{md,swap} result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/tools/pvcreate.c	2009/03/17 13:59:57	1.79
+++ LVM2/tools/pvcreate.c	2009/03/17 14:00:58	1.80
@@ -46,6 +46,7 @@
 	struct physical_volume *pv;
 	struct device *dev;
 	uint64_t md_superblock, swap_signature;
+	int wipe_md, wipe_swap;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -117,7 +118,7 @@
 	}
 
 	/* Wipe superblock? */
-	if (dev_is_md(dev, &md_superblock) &&
+	if ((wipe_md = dev_is_md(dev, &md_superblock)) == 1 &&
 	    ((!pp->idp && !pp->restorefile) || pp->yes ||
 	     (yes_no_prompt("Software RAID md superblock "
 			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
@@ -129,7 +130,13 @@
 		}
 	}
 
-	if (dev_is_swap(dev, &swap_signature) &&
+	if (wipe_md == -1) {
+		log_error("Fatal error while trying to detect software "
+			  "RAID md superblock on %s", name);
+		return 0;
+	}
+
+	if ((wipe_swap = dev_is_swap(dev, &swap_signature)) == 1 &&
 	    ((!pp->idp && !pp->restorefile) || pp->yes ||
 	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
 			    name) == 'y'))) {
@@ -140,6 +147,12 @@
 		}
 	}
 
+	if (wipe_swap == -1) {
+		log_error("Fatal error while trying to detect swap "
+			  "signature on %s", name);
+		return 0;
+	}
+
 	if (sigint_caught())
 		return 0;
 


