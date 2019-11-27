From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:33 -0500
Subject: master - pvck: use zalloc in more places
Message-ID: <87843.119112712212900709@us-mta-84.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a88b2ce7fcdffec909f7f236d9bcfe0a615b6b9
Commit:        5a88b2ce7fcdffec909f7f236d9bcfe0a615b6b9
Parent:        3145a855836c4cf50d4b6064b3e6f1ce4a366aad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 27 11:17:15 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:17:15 2019 -0600

pvck: use zalloc in more places

---
 tools/pvck.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index cc23d9b..4eaf8b4 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -226,11 +226,9 @@ static void _copy_out_metadata(char *buf, uint32_t start, uint32_t first_start,
 	/* terminating 0 byte */
 	new_len++;
 
-	if (!(new_buf = malloc(new_len)))
+	if (!(new_buf = zalloc(new_len)))
 		return;
 
-	memset(new_buf, 0, new_len);
-
 	if (len_a) {
 		memcpy(new_buf, buf+start, len_a);
 		memcpy(new_buf+len_a, buf+512, len_b);
@@ -752,9 +750,8 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!tofile)
 		return_0;
 
-	if (!(meta_buf = malloc(mda_size)))
+	if (!(meta_buf = zalloc(mda_size)))
 		return_0;
-	memset(meta_buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
@@ -2468,9 +2465,8 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 
 	text_max = back_size * 2;
 
-	if (!(text_buf = malloc(text_max)))
+	if (!(text_buf = zalloc(text_max)))
 		return_0;
-	memset(text_buf, 0, text_max);
 
 	p = back_buf;
 	text_pos = 0;



