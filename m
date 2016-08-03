From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  3 Aug 2016 03:01:04 +0000 (UTC)
Subject: master - lvconvert: Provide entry point for new functionality.
Message-ID: <20160803030104.13A1160BC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b1a368b59f0759dca84be663663011622b0cd99
Commit:        8b1a368b59f0759dca84be663663011622b0cd99
Parent:        fdc3fcbfceb6282312e79200286be29ae08a5765
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 3 03:53:29 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 3 03:53:29 2016 +0100

lvconvert: Provide entry point for new functionality.

Prepare for new segment type conversion functionality in cases that
currently fail.  In the short-term, we need to do this while limiting
the changes to the code paths for the conversions that are already
supported.
---
 tools/lvconvert.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d5eaee4..b365049 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1839,7 +1839,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (lp->mirrors_supplied && !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s.",
 			  lvseg_name(seg));
-		return 0;
+		goto try_new_takeover_or_reshape;
 	}
 
 	if (!_lvconvert_validate_thin(lv, lp))
@@ -1849,12 +1849,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		log_error("Unable to convert %s from %s to %s.",
 			  display_lvname(lv), lvseg_name(seg),
 			  lp->segtype->name);
-		return 0;
+		goto try_new_takeover_or_reshape;
 	}
 
 	if (seg_is_linear(seg) && !lp->merge_mirror && !lp->mirrors_supplied) {
 		log_error("Raid conversions require -m/--mirrors.");
-		return 0;
+		goto try_new_takeover_or_reshape;
 	}
 
 	/* Change number of RAID1 images */
@@ -1965,6 +1965,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 	log_error("Conversion operation not yet supported.");
 
+try_new_takeover_or_reshape:
+	;
+
+	/* FIXME New takeover and reshape code is called from here */
+
 	return 0;
 }
 


