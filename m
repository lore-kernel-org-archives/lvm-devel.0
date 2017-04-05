From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 5 Apr 2017 18:07:23 -0400
Subject: master - raid: tidying
Message-ID: <201704052207.v35M7No4000659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d23cad16c9210f6b01994a5e4c0637584dba80f9
Commit:        d23cad16c9210f6b01994a5e4c0637584dba80f9
Parent:        1ef1bdab27b2e2d3fb2491b42e3f7afa3b93140e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 00:06:52 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 00:06:52 2017 +0200

raid: tidying

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c7d1d76..07bb131 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1933,7 +1933,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		 * -> remove the freed up images and reduce LV size
 		 *
 		 */
-		if (!_get_available_removed_sublvs(lv, &available_slvs,  &removed_slvs))
+		if (!_get_available_removed_sublvs(lv, &available_slvs, &removed_slvs))
 			return_0;
 
 		if (devs_in_sync != new_image_count) {


