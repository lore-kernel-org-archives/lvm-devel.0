From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:36 -0400
Subject: master - mirror: improve mirror log size estimation
Message-ID: <201804201101.w3KB1aYs031160@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91965af9b1d53e6bf89ef7a849c0347277e72276
Commit:        91965af9b1d53e6bf89ef7a849c0347277e72276
Parent:        73189170f53ea661e7bf117404cdb5f461f0df1b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:12:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:11:42 2018 +0200

mirror: improve mirror log size estimation

Drop mirrored mirror log limitation that applies only in very limited
use-case and actually mirrored mirror log is deprecated anyway.

So 'disk' mirror log is selecting the correct minimal size, and
bigger size is only enforced with real mirrored mirror log.

Also for mirrored mirror log we let use 'smalled' region size if needed
so if user uses  1G region size, we still keep small mirror log
with much smaller region size in this case when needed.

Also mirror log extent calculation is now properly detecting error
with too big mirrors where previosly trimmed uint32_t was applies
unintentionally.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   21 ++++++++-------------
 lib/metadata/mirror.c   |   16 ++++++++++++----
 3 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0bb94aa..ca9e6fa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Enhance mirror log size estimation and use smaller size when possible.
   Fix incorrect mirror log size calculation on 32bit arch.
   Enhnace preloading tree creating.
   Fix regression on acceptance of any LV on lvconvert.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f275ecd..b8bbdec 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1681,19 +1681,14 @@ static uint32_t _mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint
 	log_size >>= SECTOR_SHIFT;
 	log_size = dm_div_up(log_size, pe_size);
 
-	/*
-	 * Kernel requires a mirror to be at least 1 region large.  So,
-	 * if our mirror log is itself a mirror, it must be at least
-	 * 1 region large.  This restriction may not be necessary for
-	 * non-mirrored logs, but we apply the rule anyway.
-	 *
-	 * (The other option is to make the region size of the log
-	 * mirror smaller than the mirror it is acting as a log for,
-	 * but that really complicates things.  It's much easier to
-	 * keep the region_size the same for both.)
-	 */
-	return (log_size > (region_size / pe_size)) ? log_size :
-		(region_size / pe_size);
+	if (log_size > UINT32_MAX) {
+		log_error("Log size needs too many extents "FMTu64" with region size of %u sectors.",
+			  log_size,  region_size);
+		log_size = UINT32_MAX;
+		/* VG likely will not have enough free space for this allocation -> error */
+	}
+
+	return (uint32_t) log_size;
 }
 
 /* Is there enough total space or should we give up immediately? */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d3ced60..6107619 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1805,10 +1805,18 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if ((log_count > 1) &&
-	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 2)) {
-		log_error("Failed to form mirrored log.");
-		return NULL;
+	if (log_count > 1) {
+		/* Kernel requires a mirror to be at least 1 region large. */
+		if (region_size > log_lv->size) {
+			region_size = UINT64_C(1) << (31 - clz(log_lv->size));
+			log_debug("Adjusting region_size to %s for mirrored log.",
+				  display_size(cmd, (uint64_t)region_size));
+		}
+
+		if (!_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 2)) {
+			log_error("Failed to form mirrored log.");
+			return NULL;
+		}
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {


