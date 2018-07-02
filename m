From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:27:04 -0400
Subject: master - lv_manip: do not check extents for any virtual target
Message-ID: <201807020827.w628R4Hh025980@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2b856c9940cf3b4cf4bb35bf1a145a8f5f76e13
Commit:        f2b856c9940cf3b4cf4bb35bf1a145a8f5f76e13
Parent:        2bb9627d01dc138c56d0262f918462324782d3c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:25:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:24:23 2018 +0200

lv_manip: do not check extents for any virtual target

Allow creation of any virtual segment type with just --virtualsize
specified without any real extent size give.

TODO: likely --type error,zero might be later enhanced to use -V
(along with -L) - but since those targets do not allocate real
space, supporting -V makes sense with them.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fc55c98..a382e27 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7427,7 +7427,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	lp->extents = _round_to_stripe_boundary(vg, lp->extents, lp->stripes, 1);
 
-	if (!lp->extents && !seg_is_thin_volume(lp)) {
+	if (!lp->extents && !seg_is_virtual(lp)) {
 		log_error(INTERNAL_ERROR "Unable to create new logical volume with no extents.");
 		return NULL;
 	}


