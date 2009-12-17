From: Petr Rockai <prockai@redhat.com>
Date: Thu, 17 Dec 2009 14:51:29 +0100
Subject: [PATCH] Fix removal of multiple devices from a mirror.
Message-ID: <871vitg13y.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the code for removing mirror images, as it is, shifts the first failed
leg twice and fails to shift the second failed one at all, which
reorders the mirror image array in such a way that a wrong leg is
removed as a result.

The trivial patch below fixes that behaviour by adjusting the array
pointer to accommodate for the shift. Fixes RHBZ 543225.

Yours,
   Petr.

Index: lib/metadata/mirror.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/mirror.c,v
retrieving revision 1.99
diff -u -p -r1.99 mirror.c
--- lib/metadata/mirror.c	9 Dec 2009 19:53:39 -0000	1.99
+++ lib/metadata/mirror.c	17 Dec 2009 13:43:30 -0000
@@ -533,6 +533,7 @@ static int _remove_mirror_images(struct 
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
 				if (!shift_mirror_images(mirrored_seg, s))
 					return_0;
+				s--; /* adjust counter after shifting */
 				new_area_count--;
 			}
 		}


