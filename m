From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 22:37:25 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exported.h
Message-ID: <20120212223725.31322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 22:37:24

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h 

Log message:
	FMT_INSTANCE_PV is no longer used

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2276&r2=1.2277
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.228&r2=1.229

--- LVM2/WHATS_NEW	2012/02/10 02:56:54	1.2276
+++ LVM2/WHATS_NEW	2012/02/12 22:37:24	1.2277
@@ -1,6 +1,7 @@
 Version 2.02.91 -
 ===================================
-  Refactor format instances for orphan PVs (internal).
+  Remove PV-based format instances (which are no longer needed).
+  Link all orphan PVs directly to a per-format global orphan VG.
   Refactor lvmcache around an internal API.
   Stop processing lvextend if trying to extend a mirror that is being recovered.
   Add pool_below_threshold() function to check thin pool percent status.
--- LVM2/lib/metadata/metadata-exported.h	2012/02/10 02:53:05	1.228
+++ LVM2/lib/metadata/metadata-exported.h	2012/02/12 22:37:24	1.229
@@ -200,16 +200,13 @@
 
 /*
  * These flags define the type of the format instance to be created.
- * There are two basic types: a PV-based and a VG-based format instance.
+ * There used to be a PV-based type, but all are now VG-based.
  * We can further control the format_instance initialisation and functionality
  * by using the other flags. Today, the primary role of the format_instance
  * is to temporarily store metadata area information we are working with. More
  * flags can be defined to cover even more functionality in the future...
  */
 
-/* PV-based format instance */
-#define FMT_INSTANCE_PV			0x00000000U
-
 /* VG-based format instance */
 #define FMT_INSTANCE_VG			0x00000001U
 


