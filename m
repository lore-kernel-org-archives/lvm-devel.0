From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:55 +0000 (UTC)
Subject: master - cleanup: refactor apply_lvname_restrictions
Message-ID: <20140408090255.A259B60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56175f6ba96d161a1d8f70bf985d95066b41d2d9
Commit:        56175f6ba96d161a1d8f70bf985d95066b41d2d9
Parent:        9eab84aa2b4cf97f931f0291b3f690cdceaa1e75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 20:19:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:15 2014 +0200

cleanup: refactor apply_lvname_restrictions

Split apply_lvname_restrictions into 2 internal
function:

_lvname_has_reserved_prefix()
_lvname_has_reserved_string()
---
 lib/misc/lvm-string.c |   65 ++++++++++++++++++++++++++++---------------------
 1 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index a74fd58..5377528 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -100,45 +100,59 @@ int validate_name(const char *n)
 	return (_validate_name(n) < 0 ? 0 : 1);
 }
 
-int apply_lvname_restrictions(const char *name)
+static const char *_lvname_has_reserved_prefix(const char *lvname)
 {
-	static const char * const _reserved_prefixes[] = {
-		"snapshot",
+	static const char _prefixes[][12] = {
 		"pvmove",
-		NULL
+		"snapshot"
 	};
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_prefixes); ++i)
+		if (!strncmp(lvname, _prefixes[i], strlen(_prefixes[i])))
+			return _prefixes[i];
 
-	static const char * const _reserved_strings[] = {
+	return NULL;
+}
+
+static const char *_lvname_has_reserved_string(const char *lvname)
+{
+	static const char _strings[][12] = {
 		"_cdata",
 		"_cmeta",
-		"_mlog",
 		"_mimage",
+		"_mlog",
 		"_pmspare",
 		"_rimage",
 		"_rmeta",
-		"_vorigin",
 		"_tdata",
 		"_tmeta",
-		NULL
+		"_vorigin"
 	};
-
 	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_strings); ++i)
+		if (strstr(lvname, _strings[i]))
+			return _strings[i];
+
+	return NULL;
+}
+
+
+int apply_lvname_restrictions(const char *name)
+{
 	const char *s;
 
-	for (i = 0; (s = _reserved_prefixes[i]); i++) {
-		if (!strncmp(name, s, strlen(s))) {
-			log_error("Names starting \"%s\" are reserved. "
-				  "Please choose a different LV name.", s);
-			return 0;
-		}
+	if ((s = _lvname_has_reserved_prefix(name))) {
+		log_error("Names starting \"%s\" are reserved. "
+			  "Please choose a different LV name.", s);
+		return 0;
 	}
 
-	for (i = 0; (s = _reserved_strings[i]); i++) {
-		if (strstr(name, s)) {
-			log_error("Names including \"%s\" are reserved. "
-				  "Please choose a different LV name.", s);
-			return 0;
-		}
+	if ((s = _lvname_has_reserved_string(name))) {
+		log_error("Names including \"%s\" are reserved. "
+			  "Please choose a different LV name.", s);
+		return 0;
 	}
 
 	return 1;
@@ -154,13 +168,8 @@ name_error_t validate_name_detailed(const char *name)
 
 int is_reserved_lvname(const char *name)
 {
-	int rc, old_suppress;
-
-	old_suppress = log_suppress(2);
-	rc = !apply_lvname_restrictions(name);
-	log_suppress(old_suppress);
-
-	return rc;
+	return (_lvname_has_reserved_prefix(name) ||
+		_lvname_has_reserved_string(name)) ? 1 : 0;
 }
 
 char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,


