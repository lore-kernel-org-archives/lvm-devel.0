From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:22 -0500
Subject: master - format_text: Use malloc aligned for export buffer
Message-ID: <201801101553.w0AFrMS7004701@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2438b5b9ff526cae8fa29ca7023b43995f00647
Commit:        e2438b5b9ff526cae8fa29ca7023b43995f00647
Parent:        b65246499bb126097ca8a81c3de0ca39f4f56320
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 9 21:52:19 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

format_text: Use malloc aligned for export buffer

---
 lib/format_text/export.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 1bcaf83..08e1cda 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -124,11 +124,12 @@ static int _extend_buffer(struct formatter *f)
 
 	log_debug_metadata("Doubling metadata output buffer to " FMTu32,
 			   f->data.buf.size * 2);
-	if (!(newbuf = dm_realloc(f->data.buf.start,
-				   f->data.buf.size * 2))) {
-		log_error("Buffer reallocation failed.");
-		return 0;
-	}
+	if (!(newbuf = dm_malloc_aligned(f->data.buf.size * 2, 0)))
+		return_0;
+
+	memcpy(newbuf, f->data.buf.start, f->data.buf.size);
+	free(f->data.buf.start);
+
 	f->data.buf.start = newbuf;
 	f->data.buf.size *= 2;
 
@@ -1065,7 +1066,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 		return_0;
 
 	f->data.buf.size = 65536;	/* Initial metadata limit */
-	if (!(f->data.buf.start = dm_malloc(f->data.buf.size))) {
+	if (!(f->data.buf.start = dm_malloc_aligned(f->data.buf.size, 0))) {
 		log_error("text_export buffer allocation failed");
 		goto out;
 	}


