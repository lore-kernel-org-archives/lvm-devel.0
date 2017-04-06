From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 6 Apr 2017 14:00:33 -0400
Subject: master - lvconvert: fixe conversion message
Message-ID: <201704061800.v36I0XOw014852@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb6302c8cb6bfd1d9831e5ff3d76ecbb49613178
Commit:        eb6302c8cb6bfd1d9831e5ff3d76ecbb49613178
Parent:        653bca6811d6e0928afb9de01d7baa7baaf23010
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 19:28:32 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 19:28:32 2017 +0200

lvconvert: fixe conversion message

When selecting a convenience RAID type only display
the selected type when it changed.  Display proper
current raid type when prompting.
---
 lib/metadata/raid_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f522fe2..922eea7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5734,10 +5734,11 @@ static int _set_convenient_raid1456_segtype_to(const struct lv_segment *seg_from
 replaced:
 	if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
 		return_0;
-	log_warn("Replaced LV type %s with possible type %s.",
-		 segtype_sav->name, (*segtype)->name);
+	if (segtype_sav != *segtype)
+		log_warn("Replaced LV type %s with possible type %s.",
+			 segtype_sav->name, (*segtype)->name);
 	if (!yes && yes_no_prompt("Do you want to convert %s LV %s to %s? [y/n]: ",
-				  segtype_sav->name, display_lvname(seg_from->lv),
+				  lvseg_name(seg_from), display_lvname(seg_from->lv),
 				  (*segtype)->name) == 'n') {
 		log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
 		return 0;


