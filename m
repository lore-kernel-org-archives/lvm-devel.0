From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 30 Jul 2009 19:04:40 -0400
Subject: [PATCH 2/3] Fix _mda_setup() to not check first mda's size before pe_align rounding.
In-Reply-To: <1248995081-19092-1-git-send-email-snitzer@redhat.com>
References: <1248995081-19092-1-git-send-email-snitzer@redhat.com>
Message-ID: <1248995081-19092-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Without this fix rounding the end of the first mda to a pe_align
boundary could silently exceed the disk_size.

Final 'if (start1 + mda_size1 > disk_size)' block serves as a safety
net.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   17 ++++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2630177..548cfc9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Formalize pe_start policy as split between .pv_setup and .pv_write.
   Fix lvm2app.pc installation filename.
   Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a5e6664..9ff141a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1214,6 +1214,14 @@ static int _mda_setup(const struct format_type *fmt,
 			start1 += (pagesize - mda_adjustment);
 	}
 
+	/* Round up to pe_align boundary */
+	mda_adjustment = (mda_size1 + start1) % alignment;
+	if (mda_adjustment) {
+		mda_size1 += (alignment - mda_adjustment);
+		if (start1 + mda_size1 > disk_size)
+			mda_size1 -= (alignment - mda_adjustment);
+	}
+
 	/* Ensure it's not going to be bigger than the disk! */
 	if (start1 + mda_size1 > disk_size) {
 		log_warn("WARNING: metadata area fills disk leaving no "
@@ -1221,15 +1229,14 @@ static int _mda_setup(const struct format_type *fmt,
 		/* Leave some free space for rounding */
 		/* Avoid empty data area as could cause tools problems */
 		mda_size1 = disk_size - start1 - alignment * 2;
+		/* Round up to pe_align boundary */
+		mda_adjustment = (mda_size1 + start1) % alignment;
+		if (mda_adjustment)
+			mda_size1 += (alignment - mda_adjustment);
 		/* Only have 1 mda in this case */
 		pvmetadatacopies = 1;
 	}
 
-	/* Round up to pe_align() boundary */
-	mda_adjustment = (mda_size1 + start1) % alignment;
-	if (mda_adjustment)
-		mda_size1 += (alignment - mda_adjustment);
-
 	/* If we already have PEs, avoid overlap */
 	if (pe_start || pe_end) {
 		if (pe_start <= start1)
-- 
1.6.2.5


