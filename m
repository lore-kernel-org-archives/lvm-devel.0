From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 26 Apr 2010 16:44:47 -0500
Subject: [PATCH] LVM2: Proposal #2 to fix bug 586021
Message-ID: <1272318287.29386.30.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch - in contrast to the first proposal - takes the approach that
the behavior to remove images from a mirror that were not specified when
a list of PVs was given is wrong.  The code was not adequately prepared
for this behavior change and was therefore buggy.  This patch tries to
keep the behavior change and clean-up the bugs.

Some of the decisions made in this patch have room for debate (e.g.
changing what is considered a failure for remove_mirror_images).

 brassow

Two things have been corrected in this patch to allow the
partial fulfillment of a request to reduce the number of
mirror images when an insufficient number of PVs are
specified.

1) _lvconvert_mirrors_aux was passing in the 'new log count'
   to a parameter in lv_remove_mirrors that was used to
   signify whether a log should be removed or not.  So, if
   the log count signified 'disk' or 'mirrored', it would be
   telling lv_remove_mirrors to remove the log - exactly
   opposite of what we want.  Further, the log type is adjusted
   after calling lv_remove_mirrors anyway, and should be left
   up to later code if a mirror still exists after
   lv_remove_mirrors.

2) remove_mirror_images checks if all the images it asked
   for have been removed.  If not, it returns an error.
   This error stops the processing of the images that have
   successfully been extracted from the mirror - leaving
   then lying around after completion of the command.  I
   changed the return value to success if the command had
   partial success.  If this is the desired behavior, then
   success should be returned.  This allows the process to
   continue and clean-up the images extracted from the mirror.

RFC-by Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -1063,7 +1063,7 @@ static int _lvconvert_mirrors_aux(struct
 			if (!lv_split_mirror_images(lv, lp->lv_split_name,
 						    nmc, operable_pvs))
 				return 0;
-		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
+		} else if (!lv_remove_mirrors(cmd, lv, nmc, !nlc,
 					      operable_pvs, 0))
 			return_0;
 
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -972,14 +972,13 @@ int remove_mirror_images(struct logical_
 	} while (next_lv && num_removed);
 
 	if (num_removed) {
-		if (num_removed == existing_mirrors - num_mirrors)
+		if (num_removed == existing_mirrors - num_mirrors) {
 			log_error("No mirror images found using specified PVs.");
-		else {
-			log_error("%u images are removed out of requested %u.",
-				  existing_mirrors - lv_mirror_count(lv),
-				  existing_mirrors - num_mirrors);
+			return 0;
 		}
-		return 0;
+		log_error("%u images are removed out of requested %u.",
+			  existing_mirrors - lv_mirror_count(lv),
+			  existing_mirrors - num_mirrors);
 	}
 
 	return 1;



