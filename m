From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Jun 2010 16:12:34 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100621161234.18085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-21 16:12:34

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Mirrors can be layered - as in the case of an converting 2-way
	to 3-way mirror.  When conversion operations are performed on
	these types of mirrors, log options can be confused/ignored.
	
	In the case of a converting 3-way mirror, we have a top-level
	2-way corelog mirror whose legs are 1) a 2-way disk-log mirror
	and 2) a linear device.  If we wish to convert this 3-way mirror
	to a 2-way mirror, the linear device is removed and the extra
	top layer is eliminated.  If we also wished to convert the disk
	log to a core log in the same step, ambiguity creeps in.  It is
	somewhat obvious what the user wants - a 2-way mirror with a
	corelog.  However, looking at the top level mirror before
	compression, it seems that the mirror already has a core log.
	This is why the operation seemed to fail.
	
	This patch simply re-evaluates what mirrored_seg points to after
	a compression and then considers the log argument.
	
	This is a fix for bug 599898.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1622&r2=1.1623
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/WHATS_NEW	2010/06/21 15:56:57	1.1622
+++ LVM2/WHATS_NEW	2010/06/21 16:12:33	1.1623
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Honor log argument when down-converting stacked mirror.
   Sleep to workaround clvmd -S race: socket closed early and server drops cmd.
   Use early udev synchronisation and update of dev nodes for clustered mirrors.
   Remove incorrect inclusion of kdev_t.h from cmirrord/functions.h.
--- LVM2/lib/metadata/mirror.c	2010/05/24 15:32:20	1.118
+++ LVM2/lib/metadata/mirror.c	2010/06/21 16:12:34	1.119
@@ -851,6 +851,9 @@
 			log_error("Failed to add mirror images");
 			return 0;
 		}
+		mirrored_seg = first_seg(lv);
+		if (remove_log && !detached_log_lv)
+			detached_log_lv = detach_mirror_log(mirrored_seg);
 	} else if (new_area_count == 0) {
 		log_very_verbose("All mimages of %s are gone", lv->name);
 


