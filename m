From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:17:05 +0000 (UTC)
Subject: master - cleanup: convert set of strncat into a single printf
Message-ID: <20130421211705.D62C11B9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4eb8db26ac9ddd679a32788e8d02ad1e8979e68d
Commit:        4eb8db26ac9ddd679a32788e8d02ad1e8979e68d
Parent:        4e1ac7faf132e83393dda628f72cdaecfc4bf9e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:24:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:05 2013 +0200

cleanup: convert set of strncat into a single printf

Use single snprintf for better control of used bufsize,
and also increased buffer to 128char to ensure all
chars will always fit.
---
 lib/config/config.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index d420d83..8acb87d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -337,34 +337,22 @@ int config_def_get_path(char *buf, size_t buf_size, int id)
 
 static void _get_type_name(char *buf, size_t buf_size, cfg_def_type_t type)
 {
-	buf[0] = '\0';
-
-	if (type & CFG_TYPE_ARRAY) {
-		if (type & ~CFG_TYPE_ARRAY)
-			strncat(buf, " array with values of type:", buf_size);
-		else {
-			strncat(buf, " array", buf_size);
-			return;
-		}
-	}
-
-	if (type & CFG_TYPE_SECTION)
-		strncat(buf, " section", buf_size);
-	if (type & CFG_TYPE_BOOL)
-		strncat(buf, " boolean", buf_size);
-	if (type & CFG_TYPE_INT)
-		strncat(buf, " integer", buf_size);
-	if (type & CFG_TYPE_FLOAT)
-		strncat(buf, " float", buf_size);
-	if (type & CFG_TYPE_STRING)
-		strncat(buf, " string", buf_size);
+	(void) dm_snprintf(buf, buf_size, "%s%s%s%s%s%s",
+			   (type & CFG_TYPE_ARRAY) ?
+				((type & ~CFG_TYPE_ARRAY) ?
+				 " array with values of type:" : " array") : "",
+			   (type & CFG_TYPE_SECTION) ? " section" : "",
+			   (type & CFG_TYPE_BOOL) ?  " boolean" : "",
+			   (type & CFG_TYPE_INT) ? " integer" : "",
+			   (type & CFG_TYPE_FLOAT) ?  " float" : "",
+			   (type & CFG_TYPE_STRING) ? " string" : "");
 }
 
 static void _log_type_error(const char *path, cfg_def_type_t actual,
 			    cfg_def_type_t expected, int suppress_messages)
 {
-	static char actual_type_name[64];
-	static char expected_type_name[64];
+	static char actual_type_name[128];
+	static char expected_type_name[128];
 
 	_get_type_name(actual_type_name, sizeof(actual_type_name), actual);
 	_get_type_name(expected_type_name, sizeof(expected_type_name), expected);


