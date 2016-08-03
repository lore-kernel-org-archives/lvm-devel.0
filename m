From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  3 Aug 2016 22:32:27 +0000 (UTC)
Subject: master - lvconvert: Improve error message when no -m.
Message-ID: <20160803223227.6470660B36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5de760f00de53c8035a0313f7d19ecf7e93916db
Commit:        5de760f00de53c8035a0313f7d19ecf7e93916db
Parent:        be497175e03b5cb51f2972a84528216bba06412a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 3 23:31:50 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 3 23:31:50 2016 +0100

lvconvert: Improve error message when no -m.

---
 tools/lvconvert.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b365049..6919493 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1853,7 +1853,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
-		log_error("Raid conversions require -m/--mirrors.");
+		if (_raid0_type_requested(lp->type_str))
+			log_error("Linear LV %s cannot be converted to %s.",
+				  display_lvname(lv), lp->type_str);
+		else
+			log_error("Raid conversions of LV %s require -m/--mirrors.",
+				  display_lvname(lv));
 		goto try_new_takeover_or_reshape;
 	}
 
@@ -1898,7 +1903,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		if (segtype_is_any_raid0(lp->segtype) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
 			log_error("RAID module does not support RAID0.");
-			return 0;
+			//return 0;
 		}
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size,
 				     lp->region_size, lp->pvh))


