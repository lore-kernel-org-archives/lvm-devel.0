From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:11 +0100
Subject: [PATCH 03/20] Use const char* const *
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <9f954b92fbf6421f7ae315a2e59465afe92f50d1.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix const warning for casting  char** to const char*.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |    4 ++--
 libdm/libdevmapper.h   |    2 +-
 libdm/regex/matcher.c  |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index e4d0a76..962aa1e 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -543,7 +543,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 	const struct config_node *cn;
 	const struct config_value *v;
 	struct dm_pool *scratch = NULL;
-	char **regex;
+	const char **regex;
 	unsigned count = 0;
 	int i, r = 0;
 
@@ -583,7 +583,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 	}
 
 	if (!(_cache.preferred_names_matcher =
-		dm_regex_create(_cache.mem,(const char **) regex, count))) {
+		dm_regex_create(_cache.mem, regex, count))) {
 		log_error("Preferred device name pattern matcher creation failed.");
 		goto out;
 	}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3083f9a..d385030 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1020,7 +1020,7 @@ struct dm_regex;
  * Initialise an array of num patterns for matching.
  * Uses memory from mem.
  */
-struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
+struct dm_regex *dm_regex_create(struct dm_pool *mem, const char * const *patterns,
 				 unsigned num_patterns);
 
 /*
diff --git a/libdm/regex/matcher.c b/libdm/regex/matcher.c
index eb20bd0..9590865 100644
--- a/libdm/regex/matcher.c
+++ b/libdm/regex/matcher.c
@@ -310,7 +310,7 @@ static void _force_states(struct dm_regex *m)
         }
 }
 
-struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
+struct dm_regex *dm_regex_create(struct dm_pool *mem, const char * const *patterns,
 				 unsigned num_patterns)
 {
 	char *all, *ptr;
-- 
1.7.3.3


