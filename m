From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:45 +0000 (UTC)
Subject: dev-prajnoha-selout - cleanup: use enum return codes
Message-ID: <20140509065645.D87CE60C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e416d84e1093655786b09450154779ee7896f11d
Commit:        e416d84e1093655786b09450154779ee7896f11d
Parent:        2cc02c570e489426568e57ad0b8fdbd9eedccf87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 13:52:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:46 2014 +0200

cleanup: use enum return codes

---
 lib/misc/lvm-string.c |   16 ++++++++--------
 lib/misc/lvm-string.h |   12 ++++++++----
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index cdee02b..be6298b 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -65,29 +65,29 @@ int validate_tag(const char *n)
 	return 1;
 }
 
-static int _validate_name(const char *n)
+static name_error_t _validate_name(const char *n)
 {
 	register char c;
 	register int len = 0;
 
 	if (!n || !*n)
-		return -1;
+		return NAME_INVALID_EMPTY;
 
 	/* Hyphen used as VG-LV separator - ambiguity if LV starts with it */
 	if (*n == '-')
-		return -2;
+		return NAME_INVALID_HYPEN;
 
 	if ((*n == '.') && (!n[1] || (n[1] == '.' && !n[2]))) /* ".", ".." */
-		return -3;
+		return NAME_INVALID_DOTS;
 
 	while ((len++, c = *n++))
 		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+')
-			return -4;
+			return NAME_INVALID_CHARSET;
 
 	if (len > NAME_LEN)
-		return -5;
+		return NAME_INVALID_LENGTH;
 
-	return 0;
+	return NAME_VALID;
 }
 
 /*
@@ -98,7 +98,7 @@ static int _validate_name(const char *n)
  */
 int validate_name(const char *n)
 {
-	return (_validate_name(n) < 0 ? 0 : 1);
+	return (_validate_name(n) == NAME_VALID) ? 1 : 0;
 }
 
 static const char *_lvname_has_reserved_prefix(const char *lvname)
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index a4f112f..6a13e9e 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -25,10 +25,14 @@ struct dm_pool;
 struct pool;
 struct logical_volume;
 
-typedef enum name_error { NAME_VALID = 0, NAME_INVALID_EMPTY = -1,
-					NAME_INVALID_HYPEN = -2, NAME_INVALID_DOTS = -3,
-					NAME_INVALID_CHARSET = -4, NAME_INVALID_LENGTH = -5}
-					name_error_t;
+typedef enum name_error {
+	NAME_VALID = 0,
+	NAME_INVALID_EMPTY = -1,
+	NAME_INVALID_HYPEN = -2,
+	NAME_INVALID_DOTS = -3,
+	NAME_INVALID_CHARSET = -4,
+	NAME_INVALID_LENGTH = -5
+} name_error_t;
 
 int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
   __attribute__ ((format(printf, 3, 4)));


