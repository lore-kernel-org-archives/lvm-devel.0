From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 17 Jun 2010 15:35:52 -0500
Subject: [Patch] Fix 'bz 599898 double convert of mirror ignores log option'
Message-ID: <1276806952.9735.5.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As well as opinions on the patch, I'm hoping for comments on whether it
is the right approach.  There are really 2 options:
1) disallow log conversions while mirrors are stacked
2) fix the issue, because the problem is not /that/ ambiguous just a
little tricky perhaps.
I've taken the second approach.

 brassow

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

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -851,6 +851,9 @@ static int _remove_mirror_images(struct 
 			log_error("Failed to add mirror images");
 			return 0;
 		}
+		mirrored_seg = first_seg(lv);
+		if (remove_log && !detached_log_lv)
+			detached_log_lv = detach_mirror_log(mirrored_seg);
 	} else if (new_area_count == 0) {
 		log_very_verbose("All mimages of %s are gone", lv->name);
 



