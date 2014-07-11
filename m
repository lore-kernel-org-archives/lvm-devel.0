From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:15 +0000 (UTC)
Subject: master - lv_is_pool: add new defines
Message-ID: <20140711113415.B65B160F0D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8932d4a6257cfb842adb43c71d650515ef041ba6
Commit:        8932d4a6257cfb842adb43c71d650515ef041ba6
Parent:        56c5ad7b194f5b991ae3835abca1c951450f34df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:14:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:50:06 2014 +0200

lv_is_pool: add new defines

Defines for lv_is_pool() and  lv_is_pool_metadata()
Also update comments for prompts for their current meaning.
(Though maybe they should be renamed)
---
 lib/metadata/metadata-exported.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bfb4651..f2521db 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -187,6 +187,8 @@
 #define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
 #define lv_is_virtual(lv)	(((lv)->status & (VIRTUAL)) ? 1 : 0)
+#define lv_is_pool(lv)		(((lv)->status & (CACHE_POOL | THIN_POOL)) ? 1 : 0)
+#define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & (POOL_METADATA_SPARE)) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
@@ -196,13 +198,11 @@ typedef enum {
 	AREA_LV
 } area_type_t;
 
-/*
- * Whether or not to force an operation.
- */
+/* Whether or not to force an operation */
 typedef enum {
 	PROMPT = 0, /* Issue yes/no prompt to confirm operation */
-	DONT_PROMPT = 1, /* Skip yes/no prompt */
-	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
+	DONT_PROMPT = 1, /* Add more prompts */
+	DONT_PROMPT_OVERRIDE = 2 /* Add even more dangerous prompts */
 } force_t;
 
 typedef enum {


