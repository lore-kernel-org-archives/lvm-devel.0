From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:06 +0100
Subject: [PATCH 06/23] Use outsz macro
In-Reply-To: <1259581043-15308-6-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-7-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Using outsz() macro instead of direct call of out_size() with check
for error status of this function.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mirror/mirrored.c |    4 ++--
 lib/striped/striped.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 29746b0..fa6ec04 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -149,8 +149,8 @@ static int _mirrored_text_export(const struct lv_segment *seg, struct formatter
 {
 	outf(f, "mirror_count = %u", seg->area_count);
 	if (seg->status & PVMOVE)
-		out_size(f, (uint64_t) seg->extents_copied * seg->lv->vg->extent_size,
-			 "extents_moved = %" PRIu32, seg->extents_copied);
+		outsz(f, (uint64_t) seg->extents_copied * seg->lv->vg->extent_size,
+		      "extents_moved = %" PRIu32, seg->extents_copied);
 	if (seg->log_lv)
 		outf(f, "mirror_log = \"%s\"", seg->log_lv->name);
 	if (seg->region_size)
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index f187da5..220edd8 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -98,8 +98,8 @@ static int _striped_text_export(const struct lv_segment *seg, struct formatter *
 	     (seg->area_count == 1) ? "\t# linear" : "");
 
 	if (seg->area_count > 1)
-		out_size(f, (uint64_t) seg->stripe_size,
-			 "stripe_size = %u", seg->stripe_size);
+		outsz(f, (uint64_t) seg->stripe_size,
+		      "stripe_size = %u", seg->stripe_size);
 
 	return out_areas(f, seg, "stripe");
 }
-- 
1.6.5.3


