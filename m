From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 19:50:45 +0000 (UTC)
Subject: master - systemid: Require alphanumeric 1st character.
Message-ID: <20150223195045.AE9BB60C5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0551d1c56e2e901a885aba09a94ebc391930bbc5
Commit:        0551d1c56e2e901a885aba09a94ebc391930bbc5
Parent:        a5df78e0f045e374f44be2fad3c09d44d39314f7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 19:47:03 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 19:47:03 2015 +0000

systemid: Require alphanumeric 1st character.

Require system ID to begin with an alphanumeric character.
Rename fn to make clear it's only validation for systemid
and always terminate result rather than imposing this on the caller.
---
 lib/commands/toolcontext.c |    2 +-
 lib/misc/lvm-string.c      |   32 +++++++++++---------------------
 lib/misc/lvm-string.h      |    2 +-
 3 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2e15086..190f9bd 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -65,7 +65,7 @@ char *system_id_from_string(struct cmd_context *cmd, const char *str)
 	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1)))
 		return NULL;
 
-	copy_valid_chars(str, system_id);
+	copy_systemid_chars(str, system_id);
 
 	if (!system_id[0])
 		return NULL;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 61941b3..5d63858 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -102,46 +102,36 @@ int validate_name(const char *n)
 }
 
 /*
- * Copy valid characters from source to destination.
+ * Copy valid systemid characters from source to destination.
  * Invalid characters are skipped.  Copying is stopped
  * when NAME_LEN characters have been copied.
+ * A terminating NUL is appended.
  */
-
-void copy_valid_chars(const char *src, char *dst)
+void copy_systemid_chars(const char *src, char *dst)
 {
 	const char *s = src;
 	char *d = dst;
 	int len = 0;
-	int i;
 	char c;
 
 	if (!s || !*s)
 		return;
 
-	/* Omit leading hypens. */
-	for (i = 0; i < strlen(src); i++) {
-		c = *s;
-		if (c != '-')
-			break;
+	/* Skip non-alphanumeric starting characters */
+	while (*s && !isalnum(*s))
 		s++;
-	}
-
-	for (i = 0; i < strlen(src); i++) {
-		c = *s;
 
-		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+') {
-			s++;
+	while ((c = *s++)) {
+		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+')
 			continue;
-		}
 
-		*d = *s;
-		d++;
-		s++;
-		len++;
+		*d++ = c;
 
-		if (len == NAME_LEN)
+		if (++len >= NAME_LEN)
 			break;
 	}
+
+	*d = '\0';
 }
 
 static const char *_lvname_has_reserved_prefix(const char *lvname)
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 065c19f..251aab8 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -44,7 +44,7 @@ int validate_name(const char *n);
 name_error_t validate_name_detailed(const char *n);
 int validate_tag(const char *n);
 
-void copy_valid_chars(const char *src, char *dst);
+void copy_systemid_chars(const char *src, char *dst);
 
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);


