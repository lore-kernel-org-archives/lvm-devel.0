From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:42 +0100
Subject: [PATCH 10/23] Fix memory leak of dev_filter on error path
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the allocation of peristent filter fails - its memory reference
is lost.

Also fix log_error message for failing allocation and add proper
destroy call on error path.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c      |    2 ++
 lib/filters/filter-persistent.c |   22 +++++++++++++++-------
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c4da38a..0f24ef9 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -707,6 +707,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		    cache_dir ? "" : "/",
 		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
 		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
+			f3->destroy(f3);
 			log_error("Persistent cache filename too long.");
 			return 0;
 		}
@@ -715,6 +716,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 				"%s/%s/%s.cache",
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
 				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
+		f3->destroy(f3);
 		log_error("Persistent cache filename too long.");
 		return 0;
 	}
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index f3b1e05..b8b0488 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -318,13 +318,16 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	struct dev_filter *f = NULL;
 	struct stat info;
 
-	if (!(pf = dm_zalloc(sizeof(*pf))))
-		return_NULL;
+	if (!(pf = dm_zalloc(sizeof(*pf)))) {
+		log_error("Allocation of persistent filter failed.");
+		goto fail;
+	}
 
-	if (!(pf->file = dm_malloc(strlen(file) + 1)))
-		goto_bad;
+	if (!(pf->file = dm_strdup(file))) {
+		log_error("Filename duplication for persistent filter failed.");
+		goto bad;
+	}
 
-	strcpy(pf->file, file);
 	pf->real = real;
 
 	if (!(_init_hash(pf))) {
@@ -332,8 +335,10 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 		goto bad;
 	}
 
-	if (!(f = dm_malloc(sizeof(*f))))
-		goto_bad;
+	if (!(f = dm_malloc(sizeof(*f)))) {
+		log_error("Allocation of device filter for persistent filter failed.");
+		goto bad;
+	}
 
 	/* Only merge cache file before dumping it if it changed externally. */
 	if (!stat(pf->file, &info))
@@ -352,5 +357,8 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 		dm_hash_destroy(pf->devices);
 	dm_free(pf);
 	dm_free(f);
+
+     fail:
+	real->destroy(real);
 	return NULL;
 }
-- 
1.7.3.4


