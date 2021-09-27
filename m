From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:40 +0000 (GMT)
Subject: main - metadata: optimize reading metadata copies in scan
Message-ID: <20210927165740.CCC92385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61a6f9905e87e650f0bddae83fec6923bb100a57
Commit:        61a6f9905e87e650f0bddae83fec6923bb100a57
Parent:        24e90f9594a79a8be851cffe1a5e47741dbff663
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 17:14:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:13 2021 +0200

metadata: optimize reading metadata copies in scan

While being in lockless scanning phase, we can avoid reading and checking
matching metadata copies if we already know them from other PV
and just rely on matching metadata header information.

These copies will be examined later during locked metadata read/write
access.

This patch may postpone discovering some read failures to locked phase.
---
 WHATS_NEW                     | 1 +
 lib/format_text/format-text.c | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6106edbfd..0cae2642e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Reduce metadata readings during scanning phase.
   Optimize computation of crc32 check sum with multiple PVs.
   Enhance recover path on cache creation failure.
   Filter out unsupported MQ/SMQ cache policy setting.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 29efa8ff6..b2bbf3c66 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1570,7 +1570,11 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	/* Keep track of largest metadata size we find. */
 	lvmcache_save_metadata_size(rlocn->size);
 
-	lvmcache_lookup_mda(vgsummary);
+	if (lvmcache_lookup_mda(vgsummary)) {
+		log_debug("Skipping read of already known VG metadata with matching mda checksum on %s.",
+			  dev_name(dev_area->dev));
+		goto out;
+	}
 
 	if (!text_read_metadata_summary(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
 				(off_t) (dev_area->start + rlocn->offset),
@@ -1591,7 +1595,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
 	}
-
+out:
 	log_debug_metadata("Found metadata summary on %s at %llu size %llu for VG %s",
 			   dev_name(dev_area->dev),
 			   (unsigned long long)(dev_area->start + rlocn->offset),


