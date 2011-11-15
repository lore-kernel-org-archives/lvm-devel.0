From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:23:51 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111115172351.25734.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:23:51

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin supports only thin volumes as snapshot origins
	
	It's currently of the scope to properly solve the snapshoting
	of internal thin devs so prevent non-toplevel snapshots here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.333&r2=1.334

--- LVM2/lib/metadata/lv_manip.c	2011/11/12 22:53:23	1.333
+++ LVM2/lib/metadata/lv_manip.c	2011/11/15 17:23:51	1.334
@@ -4071,6 +4071,16 @@
 					  "merging snapshot is not supported");
 				return NULL;
 			}
+
+			if (lv_is_thin_type(org) && !lv_is_thin_volume(org)) {
+				log_error("Snapshots of thin pool %sdevices "
+					  "are not supported.",
+					  lv_is_thin_pool_data(org) ? "data " :
+					  lv_is_thin_pool_metadata(org) ?
+					  "metadata " : "");
+				return NULL;
+			}
+
 			if ((org->status & MIRROR_IMAGE) ||
 			    (org->status & MIRROR_LOG)) {
 				log_error("Snapshots of mirror %ss "


