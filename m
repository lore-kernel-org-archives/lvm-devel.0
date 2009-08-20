From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 Aug 2009 07:03:03 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090820070303.8181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-08-20 07:03:02

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix uuid warning in pvcreate to use terminated (and dash formatted) UUID string.
	
	# pvcreate -u udwxr7-BoKY-EeKM-r033-xK6o-4og7-F13sGi /dev/sdc
	uuid udwxr7BoKYEeKMr033xK6o4og7F13sGi|????????? already in use on "/dev/sdb1"
	is now
	# pvcreate -u udwxr7-BoKY-EeKM-r033-xK6o-4og7-F13sGi /dev/sdc
	uuid udwxr7-BoKY-EeKM-r033-xK6o-4og7-F13sGi already in use on "/dev/sdb1"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1242&r2=1.1243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.278&r2=1.279

--- LVM2/WHATS_NEW	2009/08/19 15:34:33	1.1242
+++ LVM2/WHATS_NEW	2009/08/20 07:03:02	1.1243
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix pvcreate string termination in duplicate uuid warning message.
   Fix pvcreate on a partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
   Added configure --enable-clogd to conditionally build the cluster log daemon.
--- LVM2/lib/metadata/metadata.c	2009/08/10 17:15:01	1.278
+++ LVM2/lib/metadata/metadata.c	2009/08/20 07:03:02	1.279
@@ -1264,6 +1264,7 @@
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
+	char buffer[64] __attribute((aligned(8)));
 
 	fill_default_pvcreate_params(&default_pp);
 	if (!pp)
@@ -1272,8 +1273,11 @@
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
-			log_error("uuid %s already in use on \"%s\"",
-				  pp->idp->uuid, dev_name(dev));
+			if (!id_write_format((const struct id*)&pp->idp->uuid,
+			    buffer, sizeof(buffer)))
+				return_NULL;
+			log_error("uuid %s already in use on \"%s\"", buffer,
+				  dev_name(dev));
 			return NULL;
 		}
 	}


