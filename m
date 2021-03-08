From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:55 +0000 (GMT)
Subject: main - cleanup: on stack structure instead of allocation
Message-ID: <20210308144655.A3A873953075@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4200acac23df573717b32a44e018b30b5a90a70
Commit:        f4200acac23df573717b32a44e018b30b5a90a70
Parent:        dac990ae03f9517e050f8ea3a55529e944c60f4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 4 18:09:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

cleanup: on stack structure instead of allocation

---
 lib/format_text/export.c | 59 ++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 34 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index cdae8bc87..2253a80af 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1040,62 +1040,53 @@ static int _text_vg_export(struct formatter *f,
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp)
 {
-	struct formatter *f;
 	int r;
+	struct formatter f = {
+		.indent = 0,
+		.header = 1,
+		.out_with_comment = &_out_with_comment_file,
+		.nl = &_nl_file,
+		.data.fp = fp,
+	};
 
 	_init();
 
-	if (!(f = zalloc(sizeof(*f))))
-		return_0;
-
-	f->data.fp = fp;
-	f->indent = 0;
-	f->header = 1;
-	f->out_with_comment = &_out_with_comment_file;
-	f->nl = &_nl_file;
+	if ((r = _text_vg_export(&f, vg, desc)))
+		r = !ferror(f.data.fp);
 
-	r = _text_vg_export(f, vg, desc);
-	if (r)
-		r = !ferror(f->data.fp);
-	free(f);
 	return r;
 }
 
 /* Returns amount of buffer used incl. terminating NUL */
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf, uint32_t *buf_size)
 {
-	struct formatter *f;
-	size_t r = 0;
+	size_t r;
+	struct formatter f = {
+		.indent = 0,
+		.header = 0,
+		.out_with_comment = &_out_with_comment_raw,
+		.nl = &_nl_raw,
+		.data.buf.size = 65536,	/* Initial metadata limit */
+	};
 
 	_init();
 
-	if (!(f = zalloc(sizeof(*f))))
-		return_0;
-
-	f->data.buf.size = 65536;	/* Initial metadata limit */
-	if (!(f->data.buf.start = zalloc(f->data.buf.size))) {
+	if (!(f.data.buf.start = zalloc(f.data.buf.size))) {
 		log_error("text_export buffer allocation failed");
-		goto out;
+		return 0;
 	}
 
-	f->indent = 0;
-	f->header = 0;
-	f->out_with_comment = &_out_with_comment_raw;
-	f->nl = &_nl_raw;
-
-	if (!_text_vg_export(f, vg, desc)) {
-		free(f->data.buf.start);
-		goto_out;
+	if (!_text_vg_export(&f, vg, desc)) {
+		free(f.data.buf.start);
+		return 0;
 	}
 
-	r = f->data.buf.used + 1;
-	*buf = f->data.buf.start;
+	r = f.data.buf.used + 1;
+	*buf = f.data.buf.start;
 
 	if (buf_size)
-		*buf_size = f->data.buf.size;
+		*buf_size = f.data.buf.size;
 
-      out:
-	free(f);
 	return r;
 }
 


