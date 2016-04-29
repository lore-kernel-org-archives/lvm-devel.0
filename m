From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Apr 2016 18:48:40 +0000 (UTC)
Subject: master - datastruct: Add str_list_wipe.
Message-ID: <20160429184840.AB38F60DB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3efcdc9f5d98807ff9887aa602aff1bdc870cbd
Commit:        e3efcdc9f5d98807ff9887aa602aff1bdc870cbd
Parent:        16019b518e287da19c87eb64229f5c3ca057cb05
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 29 19:47:15 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 29 19:47:15 2016 +0100

datastruct: Add str_list_wipe.

---
 WHATS_NEW                 |    1 +
 lib/datastruct/str_list.c |   18 +++++++++++++-----
 lib/datastruct/str_list.h |    1 +
 3 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3f036e1..55ecb68 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Add str_list_wipe.
   Improve support for interrupting procesing of volumes during lvchange.
   Use failed command return code when lvchanging read-only volume.
   Show creation transaction_id and zeroing state of pool with thin volume.
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 3dfc6d7..6fe5672 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -92,7 +92,15 @@ void str_list_del(struct dm_list *sll, const char *str)
 
 	dm_list_iterate_safe(slh, slht, sll)
 		if (!strcmp(str, dm_list_item(slh, struct dm_str_list)->str))
-			 dm_list_del(slh);
+			dm_list_del(slh);
+}
+
+void str_list_wipe(struct dm_list *sll)
+{
+	struct dm_list *slh, *slht;
+
+	dm_list_iterate_safe(slh, slht, sll)
+		dm_list_del(slh);
 }
 
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
@@ -118,8 +126,8 @@ int str_list_match_item(const struct dm_list *sll, const char *str)
 	struct dm_str_list *sl;
 
 	dm_list_iterate_items(sl, sll)
-	    if (!strcmp(str, sl->str))
-		return 1;
+		if (!strcmp(str, sl->str))
+			return 1;
 
 	return 0;
 }
@@ -153,8 +161,8 @@ int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2)
 		return 0;
 
 	dm_list_iterate_items(sl, sll)
-	    if (!str_list_match_item(sll2, sl->str))
-		return 0;
+		if (!str_list_match_item(sll2, sl->str))
+			return 0;
 
 	return 1;
 }
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 82807f3..9f6d331 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -25,6 +25,7 @@ int str_list_add_list(struct dm_pool *mem, struct dm_list *sll, struct dm_list *
 int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 int str_list_add_h_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);
+void str_list_wipe(struct dm_list *sll);
 int str_list_match_item(const struct dm_list *sll, const char *str);
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);


