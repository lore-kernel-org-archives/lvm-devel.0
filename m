From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 27 Oct 2016 14:45:04 +0000 (UTC)
Subject: master - lvconvert: check for supported raid0/raid4 segtypes
Message-ID: <20161027144504.89107601EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e118b65d651d921390d3e8bbcac7170c3894d048
Commit:        e118b65d651d921390d3e8bbcac7170c3894d048
Parent:        61ae07966dfa68e7a03c054b1486136028c5c4a6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 27 16:44:32 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 27 16:44:32 2016 +0200

lvconvert: check for supported raid0/raid4 segtypes

Validate kernel support for raid0/raid4 on given and
requested segtype before requesting conversions on them.

Because raid10 wasn't present in old RAID targets, add
the same validation to be prepared once we support them.
---
 tools/lvconvert.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 90642aa..23b5906 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1963,16 +1963,24 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
 	    (lp->type_str && lp->type_str[0])) {
-		/* Activation is required later which precludes existing unsupported raid0 segment */
-		if (segtype_is_any_raid0(lp->segtype) &&
+		/* Activation is required later which precludes existing supported raid0 segment */
+		if ((seg_is_any_raid0(seg) || segtype_is_any_raid0(lp->segtype)) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
 			log_error("RAID module does not support RAID0.");
 			return 0;
 		}
 
+		/* Activation is required later which precludes existing supported raid4 segment */
 		if (!_raid4_conversion_supported(lv, lp))
 			return 0;
 
+		/* Activation is required later which precludes existing supported raid10 segment */
+		if ((seg_is_raid10(seg) || segtype_is_raid10(lp->segtype)) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID10)) {
+			log_error("RAID module does not support RAID10.");
+			return 0;
+		}
+
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
 


