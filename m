From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 13:25:11 -0500
Subject: master - raid: enhance lv_convert_raid() header relative to reshaping
Message-ID: <201703101825.v2AIPB7h021680@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9849f84b7c599953f54824bf66a8a168447e048
Commit:        d9849f84b7c599953f54824bf66a8a168447e048
Parent:        2fcbe34fe85fa57e1e2835dfba95fa21387377b6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 19:24:46 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 19:24:46 2017 +0100

raid: enhance lv_convert_raid() header relative to reshaping

---
 lib/metadata/raid_manip.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2e31bf7..9954133 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5910,10 +5910,33 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
  * Convert lv from one RAID type (or striped/mirror segtype) to new_segtype,
  * or add/remove LVs to/from a RAID LV.
  *
- * Non dm-raid changes e.g. mirror/striped functions are also called from here.
+ * Non RAID (i.e. dm-raid target relative) changes e.g. mirror/striped
+ * functions are also called from here.  This supports e.g. conversions
+ * from existing striped LVs to raid4/5/6/10 and vice versa.
  *
  * Takeover is defined as a switch from one raid level to another, potentially
  * involving the addition of one or more image component pairs and rebuild.
+ *
+ * Complementing takeover, reshaping is defined as changing properties of
+ * a RaidLV keeping the RAID level.  These properties are the RAID layout
+ * algorithm (e.g. raid5_ls vs. raid5_ra), the stripe size (e.g. 64K vs. 128K)
+ * and the number of images.
+ *
+ * RAID level specific MD kernel constraints apply to reshaping:
+ *
+ * raid4/5/6 can vary all aforementioned properties within their respective
+ * redundancy * constraints (raid4/5 minimum of 3 images and raid6 minimum
+ * of 4 images;  the latter is enforced to be 5 by lvm2.
+ *
+ * raid10 doesn't support the removal of images at all.  It can only add them.
+ *
+ * For all levels raid4/5/6/10, the stripe size
+ * may not be larger than the region size.
+ *
+ * The maximum supported image count the MD kernel supports is 253;
+ * lvm2 may enforce smaller numbers via
+ * DEFAULT_RAID_MAX_IMAGES and DEFAULT_RAID1_MAX_IMAGES.
+ *
  */
 int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,


