From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Sep 2018 16:21:23 -0400
Subject: master - metadata: remove an unused and incorrect overflow check
Message-ID: <201809202021.w8KKLNpX028186@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30c94b0324f070ea3e8b746745572580fc8e0667
Commit:        30c94b0324f070ea3e8b746745572580fc8e0667
Parent:        8424655af9eed2f2422c904f8d3fa312fe61d00f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 20 13:53:50 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 20 13:53:50 2018 -0500

metadata: remove an unused and incorrect overflow check

Remove another instance of an invalid check for metadata
overflow during read.  The previous instance was removed
in commit 5fb15b193.

This was checking for metadata that that overflowed the
circular disk metadata buffer during read, but such metadata
cannot be written, so it shouldn't be possible to find see.
Also, the check was incorrect and could trigger when there
was no overflow.
---
 lib/format_text/format-text.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7857091..04a3a8d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -567,14 +567,6 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	if (rlocn->offset + rlocn->size > mdah->size)
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
-	if (wrap > rlocn->offset) {
-		log_error("Metadata for VG %s on %s at %llu size %llu is too large for circular buffer.",
-			  vgname, dev_name(area->dev),
-			  (unsigned long long)(area->start + rlocn->offset),
-			  (unsigned long long)rlocn->size);
-		goto out;
-	}
-
 	vg = text_read_metadata(fid, NULL, vg_fmtdata, use_previous_vg, area->dev, primary_mda,
 				(off_t) (area->start + rlocn->offset),
 				(uint32_t) (rlocn->size - wrap),


