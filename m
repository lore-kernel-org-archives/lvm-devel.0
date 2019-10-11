From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Oct 2019 14:00:33 -0400
Subject: master - vgck: let updatemetadata repair mismatched metadata
Message-ID: <201910111800.x9BI0XtH024260@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd21736e8b082319e1a9a29e75badd906ee277f6
Commit:        bd21736e8b082319e1a9a29e75badd906ee277f6
Parent:        d6ffc990523468e46ae03a462ef1ec73067f9934
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 8 14:44:24 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 11 12:57:39 2019 -0500

vgck: let updatemetadata repair mismatched metadata

Let vgck --updatemetadata repair cases where different mdas
hold indepedently valid but unmatching copies of the metadata,
i.e. different text metadata checksums or text metadata sizes.
---
 lib/cache/lvmcache.c         |    1 +
 lib/cache/lvmcache.h         |    1 +
 lib/format_text/text_label.c |   25 +++++++++++++++++++------
 lib/metadata/metadata.c      |    3 +++
 lib/metadata/metadata.h      |    1 +
 5 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 316624f..f6e7924 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1649,6 +1649,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 				 vgsummary->mda_checksum, vgsummary->mda_size,
 				 vginfo->mda_checksum, vginfo->mda_size);
 			vginfo->scan_summary_mismatch = true;
+			vgsummary->mismatch = 1;
 			return 0;
 		}
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 1401974..d614e54 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -58,6 +58,7 @@ struct lvmcache_vgsummary {
 	int mda_num; /* 1 = summary from mda1, 2 = summary from mda2 */
 	unsigned mda_ignored:1;
 	unsigned zero_offset:1;
+	unsigned mismatch:1; /* lvmcache sets if this summary differs from previous values */
 	struct dm_list pvsummaries;
 };
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 41276be..246fb7b 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -507,10 +507,17 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 		if (rv1 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
 			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
 				/* I believe this is only an internal error. */
-				log_warn("WARNING: Scanning %s mda1 failed to save internal summary.", dev_name(dev));
 
 				dm_list_del(&mda1->list);
-				bad_fields |= BAD_MDA_INTERNAL;
+
+				/* Are there other cases besides mismatch and internal error? */
+				if (vgsummary.mismatch) {
+					log_warn("WARNING: Scanning %s mda1 found mismatch with other metadata.", dev_name(dev));
+					bad_fields |= BAD_MDA_MISMATCH;
+				} else {
+					log_warn("WARNING: Scanning %s mda1 failed to save internal summary.", dev_name(dev));
+					bad_fields |= BAD_MDA_INTERNAL;
+				}
 				mda1->bad_fields = bad_fields;
 				lvmcache_save_bad_mda(info, mda1);
 				mda1 = NULL;
@@ -550,11 +557,17 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 
 		if (rv2 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
 			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
-				/* I believe this is only an internal error. */
-				log_warn("WARNING: Scanning %s mda2 failed to save internal summary.", dev_name(dev));
-
 				dm_list_del(&mda2->list);
-				bad_fields |= BAD_MDA_INTERNAL;
+
+				/* Are there other cases besides mismatch and internal error? */
+				if (vgsummary.mismatch) {
+					log_warn("WARNING: Scanning %s mda2 found mismatch with other metadata.", dev_name(dev));
+					bad_fields |= BAD_MDA_MISMATCH;
+				} else {
+					log_warn("WARNING: Scanning %s mda2 failed to save internal summary.", dev_name(dev));
+					bad_fields |= BAD_MDA_INTERNAL;
+				}
+
 				mda2->bad_fields = bad_fields;
 				lvmcache_save_bad_mda(info, mda2);
 				mda2 = NULL;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 39544e6..b09f4b3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4518,6 +4518,9 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 		 * above.
 		 *
 		 * TEXT: general error related to text metadata, we can repair.
+		 *
+		 * MISMATCH: different values between instances of metadata,
+		 * can repair.
 		 */
 		if (!mda->bad_fields ||
 		    (mda->bad_fields & BAD_MDA_READ) ||
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6516e62..ac18879 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -179,6 +179,7 @@ struct metadata_area_ops {
 #define BAD_MDA_MAGIC		0x00000020
 #define BAD_MDA_VERSION		0x00000040
 #define BAD_MDA_START		0x00000080
+#define BAD_MDA_MISMATCH	0x00000100 /* lvmcache found difference from prev metadata */
 
 struct metadata_area {
 	struct dm_list list;


