From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Oct 2018 13:31:30 -0400
Subject: master - fix: cov: missed return value test
Message-ID: <201810151731.w9FHVUdI002409@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2217d6396aa6f6b8bc6421487ed6686d94668c2e
Commit:        2217d6396aa6f6b8bc6421487ed6686d94668c2e
Parent:        06a4a356dbd320e23bd95e1feb045e91c63f3d51
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 15 11:35:33 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 15 11:53:28 2018 -0500

fix: cov: missed return value test

use the existing error paths
---
 lib/format_text/format-text.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5d8355e..b41f2b2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -465,12 +465,12 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
 	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf))
-		return_NULL;
+		goto fail;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
-
+ fail:
 	log_error("Metadata on %s at %llu has wrong VG name \"%s\" expected %s.",
 		  dev_name(dev_area->dev),
 		  (unsigned long long)(dev_area->start + rlocn->offset),
@@ -1439,7 +1439,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	struct raw_locn *rlocn;
 	uint32_t wrap = 0;
 	unsigned int len = 0;
-	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+	char namebuf[NAME_LEN + 1] __attribute__((aligned(8)));
 	uint64_t max_size;
 
 	if (!mdah) {
@@ -1468,20 +1468,22 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf))
-		return_0;
+	memset(namebuf, 0, sizeof(namebuf));
+
+	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, namebuf))
+		stack;
 
-	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
+	while (namebuf[len] && !isspace(namebuf[len]) && namebuf[len] != '{' &&
 	       len < (NAME_LEN - 1))
 		len++;
 
-	buf[len] = '\0';
+	namebuf[len] = '\0';
 
 	/*
 	 * Check that the text metadata in the circular buffer begins with a
 	 * valid vg name.
 	 */
-	if (!validate_name(buf)) {
+	if (!validate_name(namebuf)) {
 		log_error("Metadata location on %s@%llu begins with invalid VG name.",
 			  dev_name(dev_area->dev),
 			  (unsigned long long)(dev_area->start + rlocn->offset));


