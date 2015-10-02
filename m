From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  2 Oct 2015 15:09:44 +0000 (UTC)
Subject: master - raid_manip: fix wrong image size allocation on raid10 "lvconvert --replace ..."
Message-ID: <20151002150944.6370161152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b33d7586e7f629818e881e26677f4431a47d50b5
Commit:        b33d7586e7f629818e881e26677f4431a47d50b5
Parent:        fb957ef3223939424cf1faff4ca9dd104882ab46
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Oct 2 17:09:37 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Oct 2 17:09:37 2015 +0200

raid_manip: fix wrong image size allocation on raid10 "lvconvert --replace ..."

---
 lib/metadata/raid_manip.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5919e3b..c420733 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -460,9 +460,12 @@ static int _alloc_image_components(struct logical_volume *lv,
 	 * individual devies, we must specify how large the individual device
 	 * is along with the number we want ('count').
 	 */
-	extents = (segtype->parity_devs) ?
-		(lv->le_count / (seg->area_count - segtype->parity_devs)) :
-		lv->le_count;
+	if (segtype_is_raid10(segtype))
+		extents = lv->le_count / (seg->area_count / 2); /* we enforce 2 mirrors right now */
+	else
+		extents = (segtype->parity_devs) ?
+			   (lv->le_count / (seg->area_count - segtype->parity_devs)) :
+			   lv->le_count;
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
 				    region_size, extents, pvs,


