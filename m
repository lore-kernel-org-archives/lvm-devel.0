From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:23 +0000 (UTC)
Subject: master - str_list: add str_list_destroy function
Message-ID: <20151030145223.E8EB9609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77605457e7cf550364355b03cb5544b57d3c046d
Commit:        77605457e7cf550364355b03cb5544b57d3c046d
Parent:        0d5b1294f0350e10698232eb764c28b3ca54df1a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 20 16:12:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

str_list: add str_list_destroy function

The str_list_destroy function may be called to cleanup memory when
the list is not used anymore and the list itself was not allocated
from the memory pool.
---
 lib/datastruct/str_list.c |   13 +++++++++++++
 lib/datastruct/str_list.h |    2 ++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index a600f60..73b5534 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -247,3 +247,16 @@ bad:
 		dm_pool_free(mem, list);
 	return NULL;
 }
+
+void str_list_destroy(struct dm_list *list, int deallocate_strings)
+{
+	struct dm_str_list *sl, *tmp_sl;
+
+	dm_list_iterate_items_safe(sl, tmp_sl, list) {
+		dm_list_del(&sl->list);
+		if (deallocate_strings)
+			dm_free((char *)sl->str);
+		dm_free(sl);
+	}
+	dm_free(list);
+}
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 268a3cf..92ff8c5 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -32,5 +32,7 @@ int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold);
 char *str_list_to_str(struct dm_pool *mem, const struct dm_list *list, const char *delim);
 struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str, const char *delim, int ignore_multiple_delim);
+/* Only for lists which were *not* allocated from the mem pool! */
+void str_list_destroy(struct dm_list *list, int deallocate_strings);
 
 #endif


