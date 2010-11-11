From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Nov 2010 12:32:35 -0000
Subject: LVM2/lib datastruct/str_list.c datastruct/str_ ...
Message-ID: <20101111123235.18232.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-11 12:32:34

Modified files:
	lib/datastruct : str_list.c str_list.h 
	lib/metadata   : lv_manip.c 

Log message:
	Preserve const for char pointer
	
	Keep char pointers 'const'  (introduced with cling commit).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237

--- LVM2/lib/datastruct/str_list.c	2010/11/09 12:34:41	1.13
+++ LVM2/lib/datastruct/str_list.c	2010/11/11 12:32:33	1.14
@@ -95,7 +95,7 @@
  * Is at least one item on both lists?
  * If tag_matched is non-NULL, it is set to the tag that matched.
  */
-int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, char **tag_matched)
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched)
 {
 	struct str_list *sl;
 
--- LVM2/lib/datastruct/str_list.h	2010/11/09 12:34:42	1.10
+++ LVM2/lib/datastruct/str_list.h	2010/11/11 12:32:33	1.11
@@ -20,7 +20,7 @@
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
 int str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
-int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, char **tag_matched);
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold);
--- LVM2/lib/metadata/lv_manip.c	2010/11/09 12:34:42	1.236
+++ LVM2/lib/metadata/lv_manip.c	2010/11/11 12:32:34	1.237
@@ -959,7 +959,7 @@
 {
 	struct config_value *cv;
 	char *str;
-	char *tag_matched;
+	const char *tag_matched;
 
 	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {


