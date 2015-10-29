From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Oct 2015 15:00:38 +0000 (UTC)
Subject: master - metadata: format_text: check metadata area size is at least MDA_SIZE_MIN
Message-ID: <20151029150038.2805F60294@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccb8da404d00288b7d49c7a28006ec5d4687bb55
Commit:        ccb8da404d00288b7d49c7a28006ec5d4687bb55
Parent:        28e54032c092ed4a5592575ac716fe698ce75d22
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 29 15:59:29 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 29 16:00:32 2015 +0100

metadata: format_text: check metadata area size is at least MDA_SIZE_MIN

---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f453604..03c70d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Check metadata area size is at least minimum size of 8 * memory page size.
   Thin pool targets uses low_water_mark from profile.
   Dropping 'yet' from error of unsupported thick snapshot of snapshots.
   Do not support unpartitioned DASD devices with CDL formatted with pvcreate.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e0ec8ed..6c653ca 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2146,7 +2146,6 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 					goto bad;
 			}
 			/* Otherwise, give up and take any usable space. */
-			/* FIXME: We should probably check for some minimum MDA size here. */
 			else
 				mda_size = limit - mda_start;
 
@@ -2242,6 +2241,12 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				 FMTu64 ").", pv_dev_name(pv),
 				  mda_size, limit_name, limit);
 
+	if (mda_size < MDA_SIZE_MIN) {
+		log_error("Metadata area size too small. "
+			  "It must be@least %u bytes.", MDA_SIZE_MIN);
+		goto bad;
+	}
+
 	if (mda_size) {
 		/* Wipe metadata area with zeroes. */
 		if (!dev_set((struct device *) pv->dev, mda_start,


