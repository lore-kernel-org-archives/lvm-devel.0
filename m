From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jun 2010 21:10:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100622211054.20114.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-22 21:10:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix "allocated" warning typo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1625&r2=1.1626
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.345&r2=1.346

--- LVM2/WHATS_NEW	2010/06/22 19:18:27	1.1625
+++ LVM2/WHATS_NEW	2010/06/22 21:10:53	1.1626
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix typo in warning message about missing device with allocated data areas.
   Add device name and offset to output of error messages in raw_read_mda_header().
   Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
   Honor log argument when down-converting stacked mirror.
--- LVM2/lib/metadata/metadata.c	2010/05/24 15:32:20	1.345
+++ LVM2/lib/metadata/metadata.c	2010/06/22 21:10:53	1.346
@@ -2604,7 +2604,7 @@
 				pv->status &= ~MISSING_PV;
 				pvl->pv->status &= ~MISSING_PV;
 			} else
-				log_warn("Device still marked missing because of alocated data "
+				log_warn("Device still marked missing because of allocated data "
 					 "on it, remove volumes and consider vgreduce --removemissing.");
 		}
 }


