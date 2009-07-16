From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jul 2009 03:25:26 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090716032526.32314.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-16 03:25:26

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Remove extraneous messages for extent_size and alloc_policy upon vgcreate.
	
	When converting to the new liblvm functions, the vgcreate code path
	changed to create a new vg, then set values.  As a result of this
	change, and the fact that we give a user a message if they try to
	set the same value of a VG attribute (extent_size, alloc_policy, etc),
	you'll see these 2 extraneous "is already" messages with vgcreate:
	tools/lvm vgcreate vg2 /dev/loop2
	Physical extent size of VG vg2 is already 4.00 MB
	Volume group allocation policy is already normal
	Volume group "vg2" successfully created
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1192&r2=1.1193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.256&r2=1.257

--- LVM2/WHATS_NEW	2009/07/16 00:52:06	1.1192
+++ LVM2/WHATS_NEW	2009/07/16 03:25:26	1.1193
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Remove unnecessary messages after vgcreate/vgsplit refactor (2.02.49).
   Add log_errno to set a specific errno and replace log_error in due course.
   Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
   Change create_toolcontext to still return an object if it fails part-way.
--- LVM2/lib/metadata/metadata.c	2009/07/15 20:02:47	1.256
+++ LVM2/lib/metadata/metadata.c	2009/07/16 03:25:26	1.257
@@ -742,7 +742,7 @@
 	}
 
 	if (new_size == vg->extent_size) {
-		log_error("Physical extent size of VG %s is already %s",
+		log_verbose("Physical extent size of VG %s is already %s",
 			  vg->name, display_size(vg->cmd, (uint64_t) new_size));
 		return 1;
 	}
@@ -933,7 +933,7 @@
 	}
 
 	if (alloc == vg->alloc) {
-		log_print("Volume group allocation policy is already %s",
+		log_verbose("Volume group allocation policy is already %s",
 			  get_alloc_string(vg->alloc));
 		return 1;
 	}


