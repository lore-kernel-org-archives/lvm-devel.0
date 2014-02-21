From: Wang Shilong <wangsl.fnst@cn.fujitsu.com>
Date: Fri, 21 Feb 2014 13:52:23 +0800
Subject: [PATCH] Enhance stripe size validation
Message-ID: <1392961943-1904-1-git-send-email-wangsl.fnst@cn.fujitsu.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>

While stripe size is twice the physical extent size, the original code will not
reduce stripe size to maximum(physical extent size).

Signed-off-by: Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>
---
 lib/metadata/lv_manip.c |    2 +-
 man/lvresize.8.in       |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2b1cdcc..14ad884 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3394,7 +3394,7 @@ static int _validate_stripesize(struct cmd_context *cmd,
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (lp->ac_stripesize_value > (uint64_t) vg->extent_size * 2) {
+	else if (lp->ac_stripesize_value >= (uint64_t) vg->extent_size * 2) {
 		log_error("Reducing stripe size %s to maximum, "
 			  "physical extent size %s",
 			  display_size(cmd,lp->ac_stripesize_value),
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 3606762..f746307 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -88,7 +88,9 @@ Defaults to whatever the last segment of the Logical Volume uses.
 Not applicable to LVs using the original metadata LVM format, which
 must use a single value throughout.
 .br
-StripeSize must be 2^n (n = 2 to 9).
+StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
+For metadata in LVM2 format, the stripe size may be a larger
+power of 2 but must not exceed the physical extent size.
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
-- 
1.7.1


