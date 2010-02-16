From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Feb 2010 01:14:34 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100216011434.24111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-02-16 01:14:34

Modified files:
	.              : WHATS_NEW 

Log message:
	use lvm2app to refer to library now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1434&r2=1.1435

--- LVM2/WHATS_NEW	2010/02/16 00:27:01	1.1434
+++ LVM2/WHATS_NEW	2010/02/16 01:14:34	1.1435
@@ -17,7 +17,7 @@
   Exit with success when lvconvert --repair --use-policies performs no action.
   Accept a list of LVs with 'lvconvert --merge @tag' using process_each_lv.
   Avoid unnecessary second resync when adding mimage to core-logged mirror.
-  Exclude internal VG names and uuids from lists returned through liblvm.
+  Exclude internal VG names and uuids from lists returned through lvm2app.
   Add %ORIGIN support to lv{create,extend,reduce,resize} --extents.
   Add _mda_copy to clone a struct metadata_area.
   Remove pointless versioned symlinks to dmeventd plugin libraries.


