From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:21 +0000 (UTC)
Subject: master - str_list: add str_list_to_str and str_to_str_list functions
Message-ID: <20151030145221.D0E2F609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d5b1294f0350e10698232eb764c28b3ca54df1a
Commit:        0d5b1294f0350e10698232eb764c28b3ca54df1a
Parent:        097d14e64e845bdb1c0b8106e33f38f775e54fe5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 20 16:01:10 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

str_list: add str_list_to_str and str_to_str_list functions

The str_list_to_str and str_to_str_list are helper functions to
convert string list to a single string and vice versa.
---
 lib/datastruct/str_list.c |   87 +++++++++++++++++++++++++++++++++++++++++++++
 lib/datastruct/str_list.h |    2 +
 2 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 25ffddd..a600f60 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -16,6 +16,8 @@
 #include "lib.h"
 #include "str_list.h"
 
+#include <ctype.h>
+
 struct dm_list *str_list_create(struct dm_pool *mem)
 {
 	struct dm_list *sl;
@@ -160,3 +162,88 @@ int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2)
 
 	return 1;
 }
+
+char *str_list_to_str(struct dm_pool *mem, const struct dm_list *list,
+		      const char *delim)
+{
+	size_t delim_len = strlen(delim);
+	unsigned list_size = dm_list_size(list);
+	struct dm_str_list *sl;
+	char *str, *p;
+	size_t len = 0;
+	unsigned i = 0;
+
+	dm_list_iterate_items(sl, list)
+		len += strlen(sl->str);
+	if (list_size > 1)
+		len += ((list_size - 1) * delim_len);
+
+	str = mem ? dm_pool_alloc(mem, len+1) : dm_malloc(len+1);
+	if (!str) {
+		log_error("str_list_to_str: string allocation failed.");
+		return NULL;
+	}
+	str[len] = '\0';
+	p = str;
+
+	dm_list_iterate_items(sl, list) {
+		len = strlen(sl->str);
+		memcpy(p, sl->str, len);
+		p += len;
+
+		if (++i != list_size) {
+			memcpy(p, delim, delim_len);
+			p += delim_len;
+		}
+	}
+
+	return str;
+}
+
+struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str,
+				const char *delim, int ignore_multiple_delim)
+{
+	size_t delim_len = strlen(delim);
+	struct dm_list *list;
+	const char *p1, *p2, *next;
+	char *str_item;
+	size_t len;
+
+	if (!(list = str_list_create(mem))) {
+		log_error("str_to_str_list: string list allocation failed.");
+		return NULL;
+	}
+
+	p1 = p2 = str;
+	while (*p1) {
+		if (!(p2 = strstr(p1, delim)))
+			next = p2 = str + strlen(str);
+		else
+			next = p2 + delim_len;
+
+		len = p2 - p1;
+		str_item = mem ? dm_pool_alloc(mem, len+1) : dm_malloc(len+1);
+		if (!str_item) {
+			log_error("str_to_str_list: string list item allocation failed.");
+			goto bad;
+		}
+		memcpy(str_item, p1, len);
+		str_item[len] = '\0';
+
+		if (!str_list_add_no_dup_check(mem, list, str_item))
+			goto_bad;
+
+		if (ignore_multiple_delim) {
+			while (!strncmp(next, delim, delim_len))
+				next += delim_len;
+		}
+
+		p1 = next;
+	}
+
+	return list;
+bad:
+	if (mem)
+		dm_pool_free(mem, list);
+	return NULL;
+}
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 3121a28..268a3cf 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -30,5 +30,7 @@ int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, c
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold);
+char *str_list_to_str(struct dm_pool *mem, const struct dm_list *list, const char *delim);
+struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str, const char *delim, int ignore_multiple_delim);
 
 #endif


