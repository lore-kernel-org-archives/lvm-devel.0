From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Tue, 6 Jun 2017 11:45:18 -0400
Subject: master - lvconvert: linear -> raid1 upconvert should cause "recover" not "resync"
Message-ID: <201706061545.v56FjIEB005051@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88e649628863e78b101c584c513053fc9461c24d
Commit:        88e649628863e78b101c584c513053fc9461c24d
Parent:        61420309ee34bb77318bf3913eb539b8f85adbda
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jun 6 10:43:12 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jun 6 10:43:12 2017 -0500

lvconvert:  linear -> raid1 upconvert should cause "recover" not "resync"

Two of the sync actions performed by the kernel (aka MD runtime) are
"resync" and "recover".  The "resync" refers to when an entirely new array
is going through the process of initializing (or resynchronizing after an
unexpected shutdown).  The "recover" is the process of initializing a new
member device to the array.  So, a brand new array with all new devices
will undergo "resync".  An array with replaced or added sub-LVs will undergo
"recover".

These two states are treated very differently when failures happen.  If any
device is lost or replaced while "resync", there are no worries.  This is
because any writes created from the inception of the array have occurred to
all the devices and can be safely recovered.  Even though non-initialized
portions will still be resync'ed with uninitialized data, it is ok.  However,
if a pre-existing device is lost (aka, the original linear device in a
linear -> raid1 convert) during a "recover", data loss can be the result.
Thus, writes are errored by the kernel and recovery is halted.  The failed
device must be restored or removed.  This is the correct behavior.

Unfortunately, we were treating an up-convert from linear as a "resync"
when we should have been treating it as a "recover".  This patch
removes the special case for linear upconvert.  It allows each new image
sub-LV to be marked with a rebuild flag and treats the array as 'in-sync'.
This has the correct effect of causing the upconvert to be treated as a
"recover" rather than a "resync".  There is no need to flag these two states
differently in LVM metadata, because they are already considered differently
by the kernel RAID metadata.  (Any activation/deactivation will properly
resume the "recover" process and not a "resync" process.)
---
 lib/metadata/raid_manip.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8c9069c..7e55530 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2559,9 +2559,6 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 	 * LV to accompany it.
 	 */
 	if (seg_is_linear(seg)) {
-		/* A complete resync will be done, no need to mark each sub-lv */
-		status_mask = ~(LV_REBUILD);
-
 		/* FIXME: allow setting region size on upconvert from linear */
 		seg->region_size = get_default_region_size(lv->vg->cmd);
 		/* MD's bitmap is limited to tracking 2^21 regions */


