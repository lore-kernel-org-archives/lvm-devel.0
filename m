From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:12 -0400
Subject: master - vgremove: fix force remove on devs with damaged metadata
Message-ID: <201804231350.w3NDoC2H031824@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e580465b50edcd5fef0eb95180a620cb785d835
Commit:        6e580465b50edcd5fef0eb95180a620cb785d835
Parent:        37471bb4777f3f407d2cd942995b45c326ea221a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 14:47:28 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

vgremove: fix force remove on devs with damaged metadata

The improved detection of bad metadata when scanning
(where errors were ignored before) means we now have to
override some errors when forcibly erasing damaged metadata.
---
 lib/format_text/format-text.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f33451f..8a42213 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -865,12 +865,28 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	int r = 0;
 	int noprecommit = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
-		goto_out;
+	if (!(mdah = dm_pool_alloc(fid->fmt->cmd->mem, MDA_HEADER_SIZE))) {
+		log_error("struct mda_header allocation failed");
+		return 0;
+	}
 
-	if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
+	/*
+	 * FIXME: what's the point of reading the mda_header and metadata,
+	 * since we zero the rlocn fields whether we can read them or not.
+	 */
+
+	if (!_raw_read_mda_header(mdah, &mdac->area, mda_is_primary(mda))) {
+		log_warn("WARNING: Removing metadata location on %s with bad mda header.",
+			  dev_name(mdac->area.dev));
 		rlocn = &mdah->raw_locns[0];
 		mdah->raw_locns[1].offset = 0;
+	} else {
+		if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
+			log_warn("WARNING: Removing metadata location on %s with bad metadata.",
+				 dev_name(mdac->area.dev));
+			rlocn = &mdah->raw_locns[0];
+			mdah->raw_locns[1].offset = 0;
+		}
 	}
 
 	rlocn->offset = 0;


