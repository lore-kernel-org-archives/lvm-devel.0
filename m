From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 15 Sep 2010 14:30:15 +0200
Subject: [PATCH] Add escape sequence for ':' in command's PV list
Message-ID: <4C90BC57.30100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is reincarnation of simple, old and forgotten (and not so important) patch
I sent a long long time ago but it faded away somehow. But I'd like to have
this cleaned up finally (..to not make a mess on my desk :)).

At that time, I used doubling of characters to escape the ":". But since
we use "\" everywhere else, let's do it this way. (rhbz #491409)

(I remember there was a discussion about adding some form of generic
mechanism for escaping characters by means of adding a new command to
do that. Do we still want that? Is that really necessary?)

Peter
---
 lib/misc/lvm-string.c |   20 ++++++++++++++++++--
 lib/misc/lvm-string.h |    6 ++++++
 tools/toollib.c       |   15 +++++++--------
 3 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 7eed799..6c1c1a5 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -105,14 +105,19 @@ static void _quote_characters(char **out, const char *src,
  * Also unquote quote_char.
  */
 static void _unquote_characters(char *src, const int orig_char,
-				const int quote_char)
+				const int quote_char,
+				char **substr_first_unquoted)
 {
 	char *out = src;
 
+	*substr_first_unquoted = NULL;
+
 	while (*src) {
 		if (*src == quote_char &&
 		    (*(src + 1) == orig_char || *(src + 1) == quote_char))
 			src++;
+		else if (*src == orig_char)
+			*substr_first_unquoted = out;
 
 		*out++ = *src++;
 	}
@@ -209,7 +214,18 @@ char *escape_double_quotes(char *out, const char *src)
  */
 void unescape_double_quotes(char *src)
 {
-	_unquote_characters(src, '\"', '\\');
+	char *s;
+
+	_unquote_characters(src, '\"', '\\', &s);
+}
+
+/*
+ * Unescape colons in situ and save the substring starting
+ * at the position of the first unescaped colon.
+ */
+void unescape_colons(char *src, char **substr_first_unquoted)
+{
+	_unquote_characters(src, ':', '\\', substr_first_unquoted);
 }
 
 /*
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 35d9245..f649fdc 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -60,4 +60,10 @@ char *escape_double_quotes(char *out, const char *src);
  */
 void unescape_double_quotes(char *src);
 
+/*
+ * Unescape colons in situ and save the substring starting
+ * at the position of the first unescaped colon.
+ */
+void unescape_colons(char *src, char **substr_first_unquoted);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 5da30f4..104f33c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1093,7 +1093,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 	struct dm_list *r;
 	struct pv_list *pvl;
 	struct dm_list tags, arg_pvnames;
-	const char *pvname = NULL;
+	char *pvname = NULL;
 	char *colon, *tagname;
 	int i;
 
@@ -1128,13 +1128,12 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 
 		pvname = argv[i];
 
-		if ((colon = strchr(pvname, ':'))) {
-			if (!(pvname = dm_pool_strndup(mem, pvname,
-						    (unsigned) (colon -
-								pvname)))) {
-				log_error("Failed to clone PV name");
-				return NULL;
-			}
+		unescape_colons(pvname, &colon);
+
+		if (colon && !(pvname = dm_pool_strndup(mem, pvname,
+					(unsigned) (colon - pvname)))) {
+			log_error("Failed to clone PV name");
+			return NULL;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pvname))) {


