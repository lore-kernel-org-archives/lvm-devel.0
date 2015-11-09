From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:51 +0000 (UTC)
Subject: master - cleanup: do not test alloca for NULL
Message-ID: <20151109092851.A8E0860F16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e04eee19213b3f498a4e8209cdcc14fcb7a0517
Commit:        2e04eee19213b3f498a4e8209cdcc14fcb7a0517
Parent:        c542c18d2af77f3114f22cf3d3845218285a5e62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 5 18:32:32 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: do not test alloca for NULL

alloca() never returns NULL.
In case stack is out-of-range the behaviour is undefined.
---
 lib/format_text/export.c |    6 +-----
 lib/metadata/mirror.c    |   20 ++++----------------
 2 files changed, 5 insertions(+), 21 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index ee9a9cf..8968f8c 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -341,11 +341,7 @@ static int _print_header(struct cmd_context *cmd, struct formatter *f,
 	outf(f, FORMAT_VERSION_FIELD " = %d", FORMAT_VERSION_VALUE);
 	outnl(f);
 
-	if (!(buf = alloca(dm_escaped_len(desc)))) {
-		log_error("temporary stack allocation for description"
-			  "string failed");
-		return 0;
-	}
+	buf = alloca(dm_escaped_len(desc));
 	outf(f, "description = \"%s\"", dm_escape_double_quotes(buf, desc));
 	outnl(f);
 	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8166e89..b69acf5 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -515,8 +515,7 @@ static int _merge_mirror_images(struct logical_volume *lv,
 	if (!addition)
 		return 1;
 
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * addition)))
-		return_0;
+	img_lvs = alloca(sizeof(*img_lvs) * addition);
 
 	dm_list_iterate_items(lvl, mimages)
 		img_lvs[i++] = lvl->lv;
@@ -1461,11 +1460,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 	size_t len;
 	
 	len = strlen(lv->name) + 32;
-	if (!(img_name = alloca(len))) {
-		log_error("img_name allocation failed. "
-			  "Remove new LV and retry.");
-		return 0;
-	}
+	img_name = alloca(len);
 
 	if (dm_snprintf(img_name, len, "%s_mimage_%%d", lv->name) < 0) {
 		log_error("img_name allocation failed. "
@@ -1861,10 +1856,7 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 	size_t len;
 
 	len = strlen(lv_name) + 32;
-	if (!(log_name = alloca(len))) {
-		log_error("log_name allocation failed.");
-		return NULL;
-	}
+	log_name = alloca(len); /* alloca never fails */
 
 	if (dm_snprintf(log_name, len, "%s%s", lv_name, suffix) < 0) {
 		log_error("log_name allocation failed.");
@@ -1903,11 +1895,7 @@ static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 	/*
 	 * create mirror image LVs
 	 */
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		return 0;
-	}
+	img_lvs = alloca(sizeof(*img_lvs) * mirrors);
 
 	if (!_create_mimage_lvs(ah, mirrors, stripes, stripe_size, lv, img_lvs, log))
 		return_0;


