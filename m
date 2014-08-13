From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Aug 2014 14:10:24 +0000 (UTC)
Subject: master - select: fix string list selection to match whole words only but not prefixes of searched string
Message-ID: <20140813141024.8C13C60E44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dd98c1fa89abb8ee9b91504a73d3a1c3f10e6d4
Commit:        6dd98c1fa89abb8ee9b91504a73d3a1c3f10e6d4
Parent:        9738a02d3d56a3a30bd8b59838eae8f805ba3bcc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 13 15:27:00 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 13 16:04:02 2014 +0200

select: fix string list selection to match whole words only but not prefixes of searched string

$ lvs -o name,tags vg/lvol0
  LV    LV Tags
  lvol0 a

Before this patch:

$ lvs -o name,tags vg/lvol0 -S 'tags=[a]'
  LV    LV Tags
  lvol0 a

$ lvs -o name,tags vg/lvol0 -S 'tags=[ab]'
  LV    LV Tags
  lvol0 a
(incorrect!)

$ lvs -o name,tags vg/lvol0 -S 'tags=[abc]'
  LV    LV Tags
  lvol0 a
(incorrect!)

With this patch applied:

$ lvs -o name,tags vg/lvol0 -S 'tags=[a]'
  LV    LV Tags
  lvol0 a

$ lvs -o name,tags vg/lvol0 -S 'tags=[ab]'
(no result - correct!)

$ lvs -o name,tags vg/lvol0 -S 'tags=[abc]'
(no result - correct!)
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 842ee15..7bb3f4c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.89 -
 =================================
+  Fix string list selection to match whole words only, not prefixes.
 
 Version 1.02.88 - 5th August 2014
 =================================
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b94cc00..620283c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1260,7 +1260,8 @@ static int _cmp_field_string_list_all(const struct str_list_sort_value *val,
 
 	/* both lists are sorted so they either match 1:1 or not */
 	dm_list_iterate_items(sel_item, sel->list) {
-		if (strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
+		if ((strlen(sel_item->str) != val->items[i].len) ||
+		    strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 			return 0;
 		i++;
 	}
@@ -1285,7 +1286,8 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 		 *       Make use of the fact that the lists are sorted!
 		 */
 		for (i = 1; i <= val->items[0].len; i++) {
-			if (!strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
+			if ((strlen(sel_item->str) == val->items[i].len) &&
+			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 				return 1;
 		}
 	}


