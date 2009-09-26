From: Daniel Mierswa <impulze@impulze.org>
Date: Sat, 26 Sep 2009 17:33:45 +0200
Subject: [PATCH 1/3] use display_size function instead of hardcoding
Message-ID: <1253979227-28051-1-git-send-email-impulze@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should use display_size everywhere for consistency reasons. Other
commands and places that print the stripe/PE size already do that.
This might break scripts that rely on the stripe/PE size being printed
in KByte in those circumstances.
This requires changes in the .po file aswell.

Signed-off-by: Daniel Mierswa <impulze@impulze.org>
---
 lib/display/display.c |    4 ++--
 lib/striped/striped.c |    4 ++--
 po/lvm2.po            |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 62f30f6..b8da95b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -344,7 +344,7 @@ void pvdisplay_full(const struct cmd_context *cmd,
 	/* LV count is no longer available when displaying PV
 	   log_print("Cur LV                %u", vg->lv_count);
 	 */
-	log_print("PE Size (KByte)       %" PRIu32, pv->pe_size / 2);
+	log_print("PE Size               %s", display_size(cmd, (uint64_t) pv->pe_size));
 	log_print("Total PE              %u", pv->pe_count);
 	log_print("Free PE               %" PRIu32, pe_free);
 	log_print("Allocated PE          %u", pv->pe_alloc_count);
@@ -489,7 +489,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	log_print("Segments               %u", dm_list_size(&lv->segments));
 
 /********* FIXME Stripes & stripesize for each segment
-	log_print("Stripe size (KByte)    %u", lv->stripesize / 2);
+	log_print("Stripe size            %s", display_size(cmd, (uint64_t) lv->stripesize));
 ***********/
 
 	log_print("Allocation             %s", get_alloc_string(lv->alloc));
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 0e1ca2d..072e34b 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -40,8 +40,8 @@ static void _striped_display(const struct lv_segment *seg)
 		display_stripe(seg, 0, "  ");
 	else {
 		log_print("  Stripes\t\t%u", seg->area_count);
-		log_print("  Stripe size\t\t%u KB", seg->stripe_size / 2);
-
+		log_print("  Stripe size\t\t%s", display_size(seg->lv->vg->cmd,
+		                                              (uint64_t) seg->stripe_size));
 		for (s = 0; s < seg->area_count; s++) {
 			log_print("  Stripe %d:", s);
 			display_stripe(seg, s, "    ");
diff --git a/po/lvm2.po b/po/lvm2.po
index 2b236ae..8a14d7b 100644
--- a/po/lvm2.po
+++ b/po/lvm2.po
@@ -1487,7 +1487,7 @@ msgstr ""
 
 #: display/display.c:312
 #, c-format
-msgid "PE Size (KByte)       %u"
+msgid "PE Size               %s"
 msgstr ""
 
 #: display/display.c:313 display/display.c:592
@@ -6510,7 +6510,7 @@ msgstr ""
 
 #: striped/striped.c:42
 #, c-format
-msgid "  Stripe size\t\t%u KB"
+msgid "  Stripe size\t\t%s"
 msgstr ""
 
 #: striped/striped.c:45
-- 
1.6.4.4


