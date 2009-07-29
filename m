From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 29 Jul 2009 16:46:17 -0400
Subject: [PATCH 1/3] Formalize pe_start policy as split between .pv_setup and .pv_write.
In-Reply-To: <1248900379-28002-1-git-send-email-snitzer@redhat.com>
References: <1248900379-28002-1-git-send-email-snitzer@redhat.com>
Message-ID: <1248900379-28002-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Document existing pe_start policy.
Fix issue in _text_pv_setup() where existing pe_start case could have
the pv->pe_start set to pv->pe_align even though pe_start shouldn't ever
change.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e31ebdf..2630177 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Formalize pe_start policy as split between .pv_setup and .pv_write.
   Fix lvm2app.pc installation filename.
   Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
   Rename lvm.h to lvm2app.h for now.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d8e03f0..a5e6664 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1595,6 +1595,13 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 };
 
 /* pvmetadatasize in sectors */
+/*
+ * pe_start policy:
+ * - In cases where a pre-existing pe_start is provided (pvcreate --restorefile
+ *   and vgconvert): pe_start must not be changed (so pv->pe_start = pe_start).
+ * - In cases where pe_start is 0: leave pv->pe_start as 0 and defer the
+ *   setting of pv->pe_start to .pv_write
+ */
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
@@ -1702,9 +1709,6 @@ static int _text_pv_setup(const struct format_type *fmt,
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
-		if (pv->pe_start < pv->pe_align)
-			pv->pe_start = pv->pe_align;
-
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-- 
1.6.2.5


