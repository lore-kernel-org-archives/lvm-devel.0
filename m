From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:11 +0000 (UTC)
Subject: master - report: add new 'none' lv_layout and 'history' lv_role and mark historical LVs that way
Message-ID: <20160303132011.E6B00602AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f47119f6fb00b685d3a631ca9464ab940ee256a
Commit:        8f47119f6fb00b685d3a631ca9464ab940ee256a
Parent:        0339a5f447f8d0b12bb874f19e84427849b33674
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:25:04 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: add new 'none' lv_layout and 'history' lv_role and mark historical LVs that way

Report proper values for historical LVs in lv_layout and lv_role fields.
Any historical LV doesn't have any layout anymore and the role is "history".

For example:

$ lvs -H -o name,lv_attr,lv_layout,lv_role vg/-lvol1
  LV     Attr       Layout     Role
  -lvol1 ----h----- none       public,history
---
 lib/metadata/lv_manip.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ed46ad3..e355cc4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -84,8 +84,10 @@ struct lv_names {
 
 enum {
 	LV_TYPE_UNKNOWN,
+	LV_TYPE_NONE,
 	LV_TYPE_PUBLIC,
 	LV_TYPE_PRIVATE,
+	LV_TYPE_HISTORY,
 	LV_TYPE_LINEAR,
 	LV_TYPE_STRIPED,
 	LV_TYPE_MIRROR,
@@ -130,8 +132,10 @@ enum {
 
 static const char *_lv_type_names[] = {
 	[LV_TYPE_UNKNOWN] =				"unknown",
+	[LV_TYPE_NONE] =				"none",
 	[LV_TYPE_PUBLIC] =				"public",
 	[LV_TYPE_PRIVATE] =				"private",
+	[LV_TYPE_HISTORY] =				"history",
 	[LV_TYPE_LINEAR] =				"linear",
 	[LV_TYPE_STRIPED] =				"striped",
 	[LV_TYPE_MIRROR] =				"mirror",
@@ -472,6 +476,12 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		goto bad;
 	}
 
+	if (lv_is_historical(lv)) {
+		if (!str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_NONE]) ||
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_HISTORY]))
+			goto_bad;
+	}
+
 	/* Mirrors and related */
 	if ((lv_is_mirror_type(lv) || lv_is_pvmove(lv)) &&
 	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role, &public_lv))


