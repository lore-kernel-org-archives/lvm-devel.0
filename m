From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Jul 2016 13:46:52 +0000 (UTC)
Subject: master - string: Add first_substring().
Message-ID: <20160714134652.2856560AB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12925d8b70c88e1a7a98e69ab896eb16ed2602fc
Commit:        12925d8b70c88e1a7a98e69ab896eb16ed2602fc
Parent:        5af311ddd8f5c03839b1c2a8feff5eb8dfde5606
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 14 14:46:38 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 14 14:46:38 2016 +0100

string: Add first_substring().

---
 lib/misc/lvm-string.c |   16 ++++++++++++++++
 lib/misc/lvm-string.h |    8 ++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 809c63c..cdcc993 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -243,3 +243,19 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 
 	return dlid;
 }
+
+char *first_substring(const char *str, ...)
+{
+	char *substr, *r = NULL;
+	va_list ap;
+
+	va_start(ap, str);
+
+	while ((substr = va_arg(ap, char *)))
+		if ((r = strstr(str, substr)))
+			break;
+
+	va_end(ap);
+
+	return r;
+}
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index d96dad5..ebdf956 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -49,4 +49,12 @@ void copy_systemid_chars(const char *src, char *dst);
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
 
+/*
+ * Provided with a NULL-terminated argument list of const char *
+ * substrings that might be contained within the string str, use
+ * strstr() to search str for each in turn and return a pointer to the
+ * first match or else NULL.
+ */
+char *first_substring(const char *str, ...);
+
 #endif


