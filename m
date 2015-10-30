From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 11:06:10 +0000 (UTC)
Subject: master - metadata: format_text: also count with calculated mda size of 0
Message-ID: <20151030110610.6771A60E71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccfc09f79b8d7ba15798a2b6f76545bb7fa3681e
Commit:        ccfc09f79b8d7ba15798a2b6f76545bb7fa3681e
Parent:        9a3b64e81ad1988f4143b5a4b4ac06eaf3035e58
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 12:02:29 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 12:02:34 2015 +0100

metadata: format_text: also count with calculated mda size of 0

When checking minimum mda size, make sure the mda_size after alignment
and calculation is more than 0 - if there's no place for an MDA at the
end of the disk, the _text_pv_add_metadata_area does not try to add it
there and it returns (because we already have the MDA at the start of
the disk at least).
---
 lib/format_text/format-text.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 29e9bd2..d4f2c89 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2241,13 +2241,13 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				 FMTu64 ").", pv_dev_name(pv),
 				  mda_size, limit_name, limit);
 
-	if (mda_size < MDA_SIZE_MIN) {
-		log_error("Metadata area size too small. "
-			  "It must be at least %u bytes.", MDA_SIZE_MIN);
-		goto bad;
-	}
-
 	if (mda_size) {
+		if (mda_size < MDA_SIZE_MIN) {
+			log_error("Metadata area size too small: %" PRIu64" bytes. "
+				  "It must be@least %u bytes.", mda_size, MDA_SIZE_MIN);
+			goto bad;
+		}
+
 		/* Wipe metadata area with zeroes. */
 		if (!dev_set((struct device *) pv->dev, mda_start,
 			(size_t) ((mda_size > wipe_size) ?


