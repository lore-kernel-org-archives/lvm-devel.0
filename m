From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:13 -0500
Subject: master - cov: use zalloc
Message-ID: <05869.119111412081001377@us-mta-153.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9af1d63b4d96facb0aa055a44c2f61eac01e13f2
Commit:        9af1d63b4d96facb0aa055a44c2f61eac01e13f2
Parent:        33c1d2e92137876116fd81cdca61874cc8e299c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:13:58 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: use zalloc

Instead of malloc() memset() -> zalloc()
---
 tools/pvck.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index c9692b0..4a267dd 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -655,9 +655,8 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!tofile)
 		return_0;
 
-	if (!(meta_buf = malloc(mda_size)))
+	if (!(meta_buf = zalloc(mda_size)))
 		return_0;
-	memset(meta_buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
@@ -713,12 +712,11 @@ static int _dump_current_text(struct device *dev,
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
 
-	if (!(meta_buf = malloc(meta_size))) {
+	if (!(meta_buf = zalloc(meta_size))) {
 		log_print("CHECK: mda_header_%d.raw_locn[%d] no mem for metadata text size %llu", mn, ri,
 			  (unsigned long long)meta_size);
 		return 0;
 	}
-	memset(meta_buf, 0, meta_size);
 
 	/*
 	 * Read the metadata text specified by the raw_locn so we can
@@ -1496,9 +1494,8 @@ static int _dump_search(struct cmd_context *cmd,
 	log_print("Searching for metadata in mda%d at offset %llu size %llu", mda_num,
 		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 
-	if (!(buf = malloc(mda_size)))
+	if (!(buf = zalloc(mda_size)))
 		return ECMD_FAILED;
-	memset(buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",



