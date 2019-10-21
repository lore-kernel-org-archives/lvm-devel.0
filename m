From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:03 -0400
Subject: master - lvm-string: add drop_lvname_suffix
Message-ID: <201910211333.x9LDX386019562@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=766dedb62899f764ef75f21b17b86c0f17f9d009
Commit:        766dedb62899f764ef75f21b17b86c0f17f9d009
Parent:        2266a1863f048899dc6f54c4d62ae05b33605349
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 09:17:57 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 12:14:15 2019 +0200

lvm-string: add drop_lvname_suffix

Internal function to drop suffix out of lvname.
---
 lib/misc/lvm-string.c |   24 ++++++++++++++++++++++++
 lib/misc/lvm-string.h |    1 +
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 4034b40..d96d431 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -290,3 +290,27 @@ char *first_substring(const char *str, ...)
 
 	return r;
 }
+
+/* Cut suffix (if present) and write the name into NAME_LEN sized new_name buffer
+ * When suffix is NULL, everythin past the last '_' is removed.
+ * Returns 1 when suffix was removed, 0 otherwise.
+ */
+int drop_lvname_suffix(char *new_name, const char *name, const char *suffix)
+{
+	char *c;
+
+	if (!dm_strncpy(new_name, name, NAME_LEN)) {
+		log_debug(INTERNAL_ERROR "Name is too long.");
+		return 0;
+	}
+
+	if (!(c = strrchr(new_name, '_')))
+		return 0;
+
+	if (suffix && strcmp(c + 1, suffix))
+		return 0;
+
+	*c = 0; /* remove suffix */
+
+	return 1;
+}
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 4e7404a..5d2f95a 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -57,5 +57,6 @@ int is_reserved_lvname(const char *name);
  * first match or else NULL.
  */
 char *first_substring(const char *str, ...);
+int drop_lvname_suffix(char *new_name, const char *name, const char *suffix);
 
 #endif


