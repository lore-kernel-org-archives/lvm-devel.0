From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:31 +0000 (GMT)
Subject: master - pvck: add simple check for fwrite
Message-ID: <20200901214131.8BFC93870874@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11f08dacc920dba49d932ccdf378331a32bad9d9
Commit:        11f08dacc920dba49d932ccdf378331a32bad9d9
Parent:        66803586ef6d7ef7bcf4260b66e85ef2fa8c7022
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 21:14:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

pvck: add simple check for fwrite

Add at least very light check for result code of fwrite().
---
 tools/pvck.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 73ef6ceff..302c74621 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -846,6 +846,7 @@ static int _dump_meta_area(struct device *dev, struct devicefile *def, const cha
 {
 	FILE *fp;
 	char *meta_buf;
+	int ret = 1;
 
 	if (!tofile)
 		return_0;
@@ -866,7 +867,11 @@ static int _dump_meta_area(struct device *dev, struct devicefile *def, const cha
 		return 0;
 	}
 
-	fwrite(meta_buf, mda_size - 512, 1, fp);
+	if (fwrite(meta_buf, mda_size - 512, 1, fp) != 1) {
+		log_error("Failed to write file %s metadata area size %llu.",
+			  tofile, (unsigned long long)mda_size);
+		ret = 0;
+	}
 
 	free(meta_buf);
 
@@ -874,7 +879,7 @@ static int _dump_meta_area(struct device *dev, struct devicefile *def, const cha
 		stack;
 	if (fclose(fp))
 		stack;
-	return 1;
+	return ret;
 }
 
 /* all sizes and offsets in bytes */


