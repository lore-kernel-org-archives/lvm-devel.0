From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 26 Apr 2010 16:44:34 -0500
Subject: [PATCH] LVM2: Proposal #1 to fix bug 586021
Message-ID: <1272318274.29386.29.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bug 586021 ("2 leg down convert request with only one PV specified
behavior changed") was exposed by the fix for 581611 ("disallow removal
of primary image when a mirror in not in-sync").  Interestingly, the
code went from doing the wrong thing and producing the right results to
doing the right thing and producing the wrong results.

These bugs partially depend on what we consider to be correct behavior
when we are asked to remove mirror images but are given insufficient
specified PVs.  When no PVs are specified, the code is free to select
any of the images in the mirror to satisfy the request.  When PVs are
specified, only those images can be used for removal.  However, when
more images are specified for removal than PVs given to satisfy the
request, things become somewhat ambiguous.  The buggy code that existed
prior to the fix for 581611 would take a hybrid approach to the problem
- ensuring the specified PVs where among those removed, but satisfying
the balance of the request from the remaining unspecified PVs.  It has
been assumed that this was the designed behavior, but I'm not so sure.
Messages like 'remove_mirror_images()log_error("%u images are removed
out of requested %u."...)' and other logic in the code seem to suggest
that this is /not/ the desired behavior.

I've produced two preliminary patches.  This first patch keeps the
historical, but arguably incorrect behavior.  The second patch will
follow in my next e-mail.  I have not yet written the necessary tests to
stress these approaches.

 brassow

Patch to fix bug 586021 and mantain historical behavior of
being able to remove more images from a mirror than the
number of PVs directly specified for removal.

The effort to fix bug 581611 corrected a bug that was unnoticed
at the time.  The loop in _remove_mirror_images that looks over
the specified PVs was allowing devices that were previously
counted and moved to the end of the list to be double-counted.
This resulted in the number of devices needed for removal always
being satisfied - even if the user did not specify enough PVs
for removal to satisfy the request.  When 581611 was fixed, this
double-counting no longer took place and the result was to remove
only the minimum of the number of PVs specified or the number
that was asked to be removed.

By simply always setting 'new_area_count' (as used to be done
only in the else statement), we return to the previous behavior.
Indeed, this is exactly what the double-counting was allowing
to happen before the fix of 581611.

RFC-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -805,8 +805,15 @@ static int _remove_mirror_images(struct 
 		}
 		if (num_removed && old_area_count == new_area_count)
 			return 1;
-	} else
-		new_area_count = old_area_count - num_removed;
+	}
+
+	/*
+	 * If removable_pvs were specified, then they have been shifted
+	 * to the end to ensure they are removed.  The remaining balance
+	 * of images left to remove will be taken from the unspecified.
+	 * This may not be correct behavior, but it is historical.
+	 */
+	new_area_count = old_area_count - num_removed;
 
 	/* Remove mimage LVs from the segment */
 	dm_list_init(&tmp_orphan_lvs);



