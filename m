From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Sep 2018 16:21:26 -0400
Subject: master - metadata: add comment about negative impact of rounding
Message-ID: <201809202021.w8KKLQw6028198@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09131e3922ffbea35733aecbc538cdbf415b43ac
Commit:        09131e3922ffbea35733aecbc538cdbf415b43ac
Parent:        30c94b0324f070ea3e8b746745572580fc8e0667
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 20 14:15:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 20 14:15:49 2018 -0500

metadata: add comment about negative impact of rounding

---
 lib/format_text/format-text.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 04a3a8d..e987849 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -486,7 +486,20 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 
 /*
  * Determine offset for new metadata
+ *
+ * Adjusting new offsets to begin on 512 boundaries is fairly new, and metadata
+ * previously begain immediately after the old, without rounding up.  The
+ * rounding should have no practical benefit since it does not affect the
+ * actual disk io.
+ *
+ * FIXME: The rounding can have a negative effect: when the current metadata
+ * text size is just below the max, a command to remove something, that
+ * *reduces* the text metadata size, can still be rejected for being too large,
+ * even though it's smaller than the current size.  In this case, the user
+ * would need to find something in the VG to remove that uses more text space
+ * to compensate for the increase due to rounding.
  */
+
 static uint64_t _next_rlocn_offset(struct raw_locn *rlocn_old, uint64_t old_last, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
 	uint64_t next_start;


