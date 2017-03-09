From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 20:12:36 -0500
Subject: master - lvconvert: fix --repair after vgreduce
Message-ID: <201703090112.v291CZIq021164@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=921b496fff51822a851447d3e8f3b93a192b4aea
Commit:        921b496fff51822a851447d3e8f3b93a192b4aea
Parent:        00b8c2bebc274ba783f6b0f0b27f07ec858c7310
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 02:11:52 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 02:11:52 2017 +0100

lvconvert: fix --repair after vgreduce

In case N images fail (N <= parity chunks) _and_
a "vgreduce --removemissing --force VG" was applied
a following repair of the RaidLV fails:

  Unable to remove N images:  Only 0 devices given.
  Failed to remove the specified images from tb/r.
  Failed to replace faulty devices in tb/r.

Fix as of this commit results in correct repair:

  Faulty devices in tb/r successfully replaced.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d109c0a..2f30252 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6275,7 +6275,7 @@ try_again:
 	 */
 	if (!_raid_extract_images(lv, force,
 				  raid_seg->area_count - match_count,
-				  partial_segment_removed ?
+				  (partial_segment_removed || !dm_list_size(remove_pvs)) ?
 				  &lv->vg->pvs : remove_pvs, 0,
 				  &old_lvs, &old_lvs)) {
 		log_error("Failed to remove the specified images from %s.",


