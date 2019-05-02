From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 May 2019 14:27:07 -0400
Subject: master - use memcpy for constant ondisk strings
Message-ID: <201905021827.x42IR7at007543@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0046c4e7a7f647096dc49df29f66bdaba4e11c00
Commit:        0046c4e7a7f647096dc49df29f66bdaba4e11c00
Parent:        adfb9bf20cd7483785bd3156f5f616b0906cd895
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 1 16:50:48 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 2 12:59:50 2019 -0500

use memcpy for constant ondisk strings

Use memcpy/memcmp for on disk strings which are not
null terminated: FMTT_MAGIC, LVM2_LABEL and LABEL_ID.
Quiets compile warnings.
---
 lib/format_text/format-text.c |    4 ++--
 lib/format_text/text_label.c  |    8 ++++----
 lib/label/label.c             |    6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d976177..3828d5f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -333,7 +333,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 
 	_xlate_mdah(mdah);
 
-	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
+	if (memcmp(mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
 		log_error("Wrong magic number in metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
@@ -378,7 +378,7 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 				 struct device *dev, int primary_mda,
 				 uint64_t start_byte, struct mda_header *mdah)
 {
-	strncpy((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic));
+	memcpy(mdah->magic, FMTT_MAGIC, sizeof(mdah->magic));
 	mdah->version = FMTT_VERSION;
 	mdah->start = start_byte;
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 1157b98..ef2f6c7 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -30,7 +30,7 @@ static int _text_can_handle(struct labeller *l __attribute__((unused)),
 {
 	struct label_header *lh = (struct label_header *) buf;
 
-	if (!strncmp((char *)lh->type, LVM2_LABEL, sizeof(lh->type)))
+	if (!memcmp(lh->type, LVM2_LABEL, sizeof(lh->type)))
 		return 1;
 
 	return 0;
@@ -95,9 +95,9 @@ static int _text_write(struct label *label, void *buf)
 	 * PV header base
 	 */
 	/* FIXME Move to where label is created */
-	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
+	memcpy(label->type, LVM2_LABEL, sizeof(label->type));
 
-	strncpy((char *)lh->type, label->type, sizeof(label->type));
+	memcpy(lh->type, LVM2_LABEL, sizeof(lh->type));
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;
@@ -314,7 +314,7 @@ void del_mdas(struct dm_list *mdas)
 static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 				  struct label *label)
 {
-	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
+	memcpy(label->type, LVM2_LABEL, sizeof(label->type));
 
 	return 1;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index 3b9d9fd..31b290b 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -139,7 +139,7 @@ int label_remove(struct device *dev)
 
 		wipe = 0;
 
-		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
+		if (!memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (xlate64(lh->sector_xl) == sector)
 				wipe = 1;
 		} else {
@@ -192,7 +192,7 @@ int label_write(struct device *dev, struct label *label)
 
 	memset(buf, 0, LABEL_SIZE);
 
-	strncpy((char *)lh->id, LABEL_ID, sizeof(lh->id));
+	memcpy(lh->id, LABEL_ID, sizeof(lh->id));
 	lh->sector_xl = xlate64(label->sector);
 	lh->offset_xl = xlate32(sizeof(*lh));
 
@@ -293,7 +293,7 @@ static struct labeller *_find_lvm_header(struct device *dev,
 
 		lh = (struct label_header *) (scan_buf + (sector << SECTOR_SHIFT));
 
-		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
+		if (!memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
 				log_error("Ignoring additional label on %s at sector %llu",
 					  dev_name(dev), (unsigned long long)(block_sector + sector));


