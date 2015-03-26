From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Mar 2015 18:31:43 +0000 (UTC)
Subject: master - datastruct: Add str_list_add_list.
Message-ID: <20150326183143.7BD1060324@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9506760c7ec86448e54803a74ade58d24d975ff1
Commit:        9506760c7ec86448e54803a74ade58d24d975ff1
Parent:        8a87fadbb026ca121c8af8669e68673aece46eb2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 26 18:30:37 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 26 18:30:37 2015 +0000

datastruct: Add str_list_add_list.

---
 WHATS_NEW                 |    1 +
 lib/datastruct/str_list.c |   15 +++++++++++++++
 lib/datastruct/str_list.h |    1 +
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4010e67..f2d5b80 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Add str_list_add_list() to combine two lists.
   Fix LV processing with selection to always do the selection on initial state.
 
 Version 2.02.118 - 23rd March 2015
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index feec8b6..1d3f08a 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -71,6 +71,21 @@ int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 	return str_list_add_no_dup_check(mem, sll, str);
 }
 
+/* Add contents of sll2 to sll */
+int str_list_add_list(struct dm_pool *mem, struct dm_list *sll, struct dm_list *sll2)
+{
+	struct dm_str_list *sl;
+
+	if (!sll2)
+		return_0;
+
+	dm_list_iterate_items(sl, sll2)
+		if (!str_list_add(mem, sll, sl->str))
+			return_0;
+
+	return 1;
+}
+
 void str_list_del(struct dm_list *sll, const char *str)
 {
 	struct dm_list *slh, *slht;
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 0046fe4..3121a28 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -21,6 +21,7 @@ struct dm_pool;
 
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
+int str_list_add_list(struct dm_pool *mem, struct dm_list *sll, struct dm_list *sll2);
 int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 int str_list_add_h_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);


