From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jul 2009 20:18:16 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090716201816.30094.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-16 20:18:16

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove 'is already' message from vg_set_* functions.
	
	These messages are unnecessary in the set functions.  We check for this
	condition and print a message in the vgchange tool but not the library
	functions.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.257&r2=1.258

--- LVM2/lib/metadata/metadata.c	2009/07/16 03:25:26	1.257
+++ LVM2/lib/metadata/metadata.c	2009/07/16 20:18:16	1.258
@@ -741,11 +741,8 @@
 		return 0;
 	}
 
-	if (new_size == vg->extent_size) {
-		log_verbose("Physical extent size of VG %s is already %s",
-			  vg->name, display_size(vg->cmd, (uint64_t) new_size));
+	if (new_size == vg->extent_size)
 		return 1;
-	}
 
 	if (new_size & (new_size - 1)) {
 		log_error("Physical extent size must be a power of 2.");
@@ -932,11 +929,9 @@
 		return 0;
 	}
 
-	if (alloc == vg->alloc) {
-		log_verbose("Volume group allocation policy is already %s",
-			  get_alloc_string(vg->alloc));
+	if (alloc == vg->alloc)
 		return 1;
-	}
+
 	vg->alloc = alloc;
 	return 1;
 }


