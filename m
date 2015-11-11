From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Nov 2015 15:11:17 +0000 (UTC)
Subject: master - str_list: do not support str lists without mempools
Message-ID: <20151111151117.8778D602B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e729c47d2cdc6591a41f159f84be39ffcc6c200
Commit:        1e729c47d2cdc6591a41f159f84be39ffcc6c200
Parent:        b8779e706e1019a8e8212d81bde0cc7e42be5426
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 11 16:09:39 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 11 16:09:52 2015 +0100

str_list: do not support str lists without mempools

Do not support str lists without mempools. Instead, create temporary
mempool where necessary (currently only _get_report_options fn).
---
 lib/datastruct/str_list.c |   23 ++++-------------------
 lib/datastruct/str_list.h |    2 --
 tools/reporter.c          |   32 +++++++++++++-------------------
 3 files changed, 17 insertions(+), 40 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index f056b85..cf7457b 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -20,8 +20,7 @@ struct dm_list *str_list_create(struct dm_pool *mem)
 {
 	struct dm_list *sl;
 
-	if (!(sl = mem ? dm_pool_alloc(mem, sizeof(struct dm_list))
-		       : dm_malloc(sizeof(struct dm_list)))) {
+	if (!(sl = dm_pool_alloc(mem, sizeof(struct dm_list)))) {
 		log_errno(ENOMEM, "str_list allocation failed");
 		return NULL;
 	}
@@ -38,8 +37,7 @@ static int _str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll,
 	if (!str)
 		return_0;
 
-	if (!(sln = mem ? dm_pool_alloc(mem, sizeof(*sln))
-			: dm_malloc(sizeof(*sln))))
+	if (!(sln = dm_pool_alloc(mem, sizeof(*sln))))
 		return_0;
 
 	sln->str = str;
@@ -176,7 +174,7 @@ char *str_list_to_str(struct dm_pool *mem, const struct dm_list *list,
 	if (list_size > 1)
 		len += ((list_size - 1) * delim_len);
 
-	str = mem ? dm_pool_alloc(mem, len+1) : dm_malloc(len+1);
+	str = dm_pool_alloc(mem, len+1);
 	if (!str) {
 		log_error("str_list_to_str: string allocation failed.");
 		return NULL;
@@ -220,7 +218,7 @@ struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str,
 			next = p2 + delim_len;
 
 		len = p2 - p1;
-		str_item = mem ? dm_pool_alloc(mem, len+1) : dm_malloc(len+1);
+		str_item = dm_pool_alloc(mem, len+1);
 		if (!str_item) {
 			log_error("str_to_str_list: string list item allocation failed.");
 			goto bad;
@@ -245,16 +243,3 @@ bad:
 		dm_pool_free(mem, list);
 	return NULL;
 }
-
-void str_list_destroy(struct dm_list *list, int deallocate_strings)
-{
-	struct dm_str_list *sl, *tmp_sl;
-
-	dm_list_iterate_items_safe(sl, tmp_sl, list) {
-		dm_list_del(&sl->list);
-		if (deallocate_strings)
-			dm_free((char *)sl->str);
-		dm_free(sl);
-	}
-	dm_free(list);
-}
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 92ff8c5..268a3cf 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -32,7 +32,5 @@ int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold);
 char *str_list_to_str(struct dm_pool *mem, const struct dm_list *list, const char *delim);
 struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str, const char *delim, int ignore_multiple_delim);
-/* Only for lists which were *not* allocated from the mem pool! */
-void str_list_destroy(struct dm_list *list, int deallocate_strings);
 
 #endif
diff --git a/tools/reporter.c b/tools/reporter.c
index 89024c2..2c733e3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -651,13 +651,18 @@ static int _get_report_options(struct cmd_context *cmd,
 	struct dm_list *final_opts_list;
 	struct dm_list *final_compact_list = NULL;
 	struct dm_list *opts_list = NULL;
-	int opts_list_destroy = 1;
 	struct dm_str_list *sl;
 	const char *opts;
+	struct dm_pool *mem;
 	int r = ECMD_PROCESSED;
 
+	if (!(mem = dm_pool_create("report_options", 128))) {
+		r = ECMD_FAILED;
+		log_error("Failed to create temporary mempool to process report options.");
+		goto_out;
+	}
 
-	if (!(final_opts_list = str_to_str_list(NULL, *options, ",", 1))) {
+	if (!(final_opts_list = str_to_str_list(mem, *options, ",", 1))) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
@@ -679,7 +684,7 @@ static int _get_report_options(struct cmd_context *cmd,
 			case '-':
 				/* fall through */
 			case '#':
-				if (!(opts_list = str_to_str_list(NULL, opts + 1, ",", 1))) {
+				if (!(opts_list = str_to_str_list(mem, opts + 1, ",", 1))) {
 					r = ECMD_FAILED;
 					goto_out;
 				}
@@ -690,21 +695,14 @@ static int _get_report_options(struct cmd_context *cmd,
 						_del_option_from_list(final_opts_list, prefix,
 								      prefix_len, sl->str);
 				} else if (*opts == '#') {
-					if (!final_compact_list) {
+					if (!final_compact_list)
 						final_compact_list = opts_list;
-						opts_list_destroy = 0;
-					} else
+					else
 						dm_list_splice(final_compact_list, opts_list);
 				}
-				if (opts_list_destroy)
-					str_list_destroy(opts_list, 1);
-				else
-					opts_list_destroy = 1;
-				opts_list = NULL;
 				break;
 			default:
-				str_list_destroy(final_opts_list, 1);
-				if (!(final_opts_list = str_to_str_list(NULL, opts, ",", 1))) {
+				if (!(final_opts_list = str_to_str_list(mem, opts, ",", 1))) {
 					r = ECMD_FAILED;
 					goto out;
 				}
@@ -722,12 +720,8 @@ static int _get_report_options(struct cmd_context *cmd,
 		goto out;
 	}
 out:
-	if (opts_list)
-		str_list_destroy(final_opts_list, 1);
-	if (final_compact_list)
-		str_list_destroy(final_compact_list, 1);
-	if (final_opts_list)
-		str_list_destroy(final_opts_list, 1);
+	if (mem)
+		dm_pool_destroy(mem);
 	return r;
 }
 


