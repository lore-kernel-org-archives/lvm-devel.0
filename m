From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:34 +0000 (GMT)
Subject: main - lvcreate: code move
Message-ID: <20220126141034.B9B613850423@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f1f7ad694201533c04ddfbe9ba047f832b38750
Commit:        7f1f7ad694201533c04ddfbe9ba047f832b38750
Parent:        89cec5b65af5533bcde358d8d4f7d1d5701a341b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 18 17:33:53 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

lvcreate: code move

---
 tools/lvcreate.c | 48 ++++++++++++++++++++++--------------------------
 1 file changed, 22 insertions(+), 26 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2c519d555..b58fd62bb 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1851,30 +1851,28 @@ static int _lvcreate_and_attach_writecache_single(struct cmd_context *cmd,
 int lvcreate_and_attach_writecache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle = NULL;
-	struct processing_params pp;
 	struct lvcreate_params lp = {
 		.major = -1,
 		.minor = -1,
+		/*
+		 * Tell lvcreate to ignore --type since we are using lvcreate
+		 * to create a linear LV and using lvconvert to add cache.
+		 * (Would be better if lvcreate code was split up so we could
+		 * call a specific function that just created a linear/striped LV.)
+		 */
+		.ignore_type = 1,
 	};
 	struct lvcreate_cmdline_params lcp = { 0 };
+	struct processing_params pp = {
+	    .lp = &lp,
+	    .lcp = &lcp,
+	};
 	int ret;
-
-	/*
-	 * Tell lvcreate to ignore --type since we are using lvcreate
-	 * to create a linear LV and using lvconvert to add cache.
-	 * (Would be better if lvcreate code was split up so we could
-	 * call a specific function that just created a linear/striped LV.)
-	 */
-	lp.ignore_type = 1;
-
 	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
 
-	pp.lp = &lp;
-	pp.lcp = &lcp;
-
         if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -1925,30 +1923,29 @@ static int _lvcreate_and_attach_cache_single(struct cmd_context *cmd,
 int lvcreate_and_attach_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle = NULL;
-	struct processing_params pp;
 	struct lvcreate_params lp = {
 		.major = -1,
 		.minor = -1,
+		/*
+		 * Tell lvcreate to ignore --type since we are using lvcreate
+		 * to create a linear LV and using lvconvert to add cache.
+		 * (Would be better if lvcreate code was split up so we could
+		 * call a specific function that just created a linear/striped LV.)
+		 */
+		.ignore_type = 1,
 	};
 	struct lvcreate_cmdline_params lcp = { 0 };
+	struct processing_params pp = {
+	    .lp = &lp,
+	    .lcp = &lcp,
+	};
 	int ret;
 
-	/*
-	 * Tell lvcreate to ignore --type since we are using lvcreate
-	 * to create a linear LV and using lvconvert to add cache.
-	 * (Would be better if lvcreate code was split up so we could
-	 * call a specific function that just created a linear/striped LV.)
-	 */
-	lp.ignore_type = 1;
-
 	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
 
-	pp.lp = &lp;
-	pp.lcp = &lcp;
-
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -1963,4 +1960,3 @@ int lvcreate_and_attach_cache_cmd(struct cmd_context *cmd, int argc, char **argv
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
-


