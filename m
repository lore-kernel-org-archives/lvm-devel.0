From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:52 -0500
Subject: master - Revert "cov: use zalloc"
Message-ID: <22700.119112712205001240@us-mta-400.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13c629fb7840e73a38afb9396cae93ea10955a21
Commit:        13c629fb7840e73a38afb9396cae93ea10955a21
Parent:        39bd9b111bc6d2bcb56dfc5859e691b9c90db4c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:31:31 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:43 2019 -0600

Revert "cov: use zalloc"

This reverts commit 9af1d63b4d96facb0aa055a44c2f61eac01e13f2.

fixes folded into subsequent pvck commit
---
 tools/pvck.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index ab3f7db..231faf9 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -652,8 +652,9 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!tofile)
 		return_0;
 
-	if (!(meta_buf = zalloc(mda_size)))
+	if (!(meta_buf = malloc(mda_size)))
 		return_0;
+	memset(meta_buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
@@ -704,11 +705,12 @@ static int _dump_current_text(struct device *dev,
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
 
-	if (!(meta_buf = zalloc(meta_size))) {
+	if (!(meta_buf = malloc(meta_size))) {
 		log_print("CHECK: mda_header_%d.raw_locn[%d] no mem for metadata text size %llu", mn, ri,
 			  (unsigned long long)meta_size);
 		return 0;
 	}
+	memset(meta_buf, 0, meta_size);
 
 	/*
 	 * Read the metadata text specified by the raw_locn so we can
@@ -1482,8 +1484,9 @@ static int _dump_search(struct cmd_context *cmd,
 	log_print("Searching for metadata in mda%d at offset %llu size %llu", mda_num,
 		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 
-	if (!(buf = zalloc(mda_size)))
+	if (!(buf = malloc(mda_size)))
 		return ECMD_FAILED;
+	memset(buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",



