From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Aug 2010 23:03:36 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100819230336.24367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-19 23:03:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Change the pvcreate swap/md logic
	
	pvcreate detects MD and swap signature.
	
	The logic hidden there is not only documented but it is also
	user unfriendly. Who invented this logic should run pvcreate
	on its own critical MD device to see why;-)
	
	This patch
	- creates one function instead of duplication code
	- asks if user want to overwrite signature
	- allows aborting (!)
	(Please note that writing LVM signatute without wiping old
	is wrong, it confuses blkid, MD will not work anyway and
	swap and LUKS is broken too.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1712&r2=1.1713
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.391&r2=1.392

--- LVM2/WHATS_NEW	2010/08/19 22:33:14	1.1712
+++ LVM2/WHATS_NEW	2010/08/19 23:03:34	1.1713
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Simplify MD/swap signature detection in pvcreate and allow aborting.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/lib/metadata/metadata.c	2010/08/12 04:11:49	1.391
+++ LVM2/lib/metadata/metadata.c	2010/08/19 23:03:35	1.392
@@ -1526,6 +1526,40 @@
 	return 1;
 }
 
+static int _wipe_sb(struct device *dev, const char *type, const char *name,
+		    int wipe_len, struct pvcreate_params *pp,
+		    int (*func)(struct device *dev, uint64_t *signature))
+{
+	int wipe;
+	uint64_t superblock;
+
+	wipe = func(dev, &superblock);
+	if (wipe == -1) {
+		log_error("Fatal error while trying to detect %s on %s.",
+			  type, name);
+		return 0;
+	}
+
+	if (wipe == 0)
+		return 1;
+
+	/* Specifying --yes => do not ask. */
+	if (!pp->yes && (pp->force == PROMPT) &&
+	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n] ",
+			  type, name) != 'y') {
+		log_error("Aborting pvcreate on %s.", name);
+		return 0;
+	}
+
+	log_print("Wiping %s on %s.", type, name);
+	if (!dev_set(dev, superblock, wipe_len, 0)) {
+		log_error("Failed to wipe %s on %s.", type, name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
@@ -1535,8 +1569,6 @@
 {
 	struct physical_volume *pv;
 	struct device *dev;
-	uint64_t md_superblock, swap_signature;
-	int wipe_md, wipe_swap;
 	struct dm_list mdas;
 
 	dm_list_init(&mdas);
@@ -1602,41 +1634,11 @@
 		return 0;
 	}
 
-	/* Wipe superblock? */
-	if ((wipe_md = dev_is_md(dev, &md_superblock)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Software RAID md superblock "
-			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
-		log_print("Wiping software RAID md superblock on %s", name);
-		if (!dev_set(dev, md_superblock, 4, 0)) {
-			log_error("Failed to wipe RAID md superblock on %s",
-				  name);
-			return 0;
-		}
-	}
-
-	if (wipe_md == -1) {
-		log_error("Fatal error while trying to detect software "
-			  "RAID md superblock on %s", name);
+	if (!_wipe_sb(dev, "software RAID md superblock", name, 4, pp, dev_is_md))
 		return 0;
-	}
-
-	if ((wipe_swap = dev_is_swap(dev, &swap_signature)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
-			    name) == 'y'))) {
-		log_print("Wiping swap signature on %s", name);
-		if (!dev_set(dev, swap_signature, 10, 0)) {
-			log_error("Failed to wipe swap signature on %s", name);
-			return 0;
-		}
-	}
 
-	if (wipe_swap == -1) {
-		log_error("Fatal error while trying to detect swap "
-			  "signature on %s", name);
+	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
 		return 0;
-	}
 
 	if (sigint_caught())
 		return 0;


