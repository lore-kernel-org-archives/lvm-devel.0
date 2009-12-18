From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 18 Dec 2009 12:45:42 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20091218124542.3474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-18 12:45:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Drop metadata cache after device was autorepaired and removed from VG.
	
	All long running processes must reload metadata when some
	device becomes orphan after repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1353&r2=1.1354
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.305&r2=1.306

--- LVM2/WHATS_NEW	2009/12/18 12:44:20	1.1353
+++ LVM2/WHATS_NEW	2009/12/18 12:45:41	1.1354
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Drop metadata cache after device was autorepaired and removed from VG.
   Remove missing flag in metadata if PV reappeared and is empty.
   Destroy allocated mempool in _vg_read_orphans() error path.
   Fix unlocking vg in some pvresize and toollib error paths.
--- LVM2/lib/metadata/metadata.c	2009/12/18 12:44:20	1.305
+++ LVM2/lib/metadata/metadata.c	2009/12/18 12:45:41	1.306
@@ -2794,6 +2794,9 @@
 				vg_release(correct_vg);
 				return_NULL;
 			}
+
+			/* Refresh metadata after orphan write */
+			drop_cached_metadata(correct_vg);
       next_pv:
 			;
 		}


