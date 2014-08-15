From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:33:29 +0000 (UTC)
Subject: master - cleanup: gcc warning
Message-ID: <20140815133329.B85B0612EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e449ebd63228bb8728d7e62989dc1254138b153
Commit:        8e449ebd63228bb8728d7e62989dc1254138b153
Parent:        d213758e5720f47d3a5781d958431c8d80afdda7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 15:32:04 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 15:32:04 2014 +0200

cleanup: gcc warning

metadata/lv_manip.c:269: warning: declaration of "snapshot_count" shadows a global declaration

There's existing function called "snapshot_count" so rename the
variable to "snap_count".
---
 lib/metadata/lv_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 35b898f..d86bdc1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -266,7 +266,7 @@ static int _lv_type_list_thin(struct dm_pool *mem,
 			      struct dm_list *type)
 {
 	int top_level = 1;
-	unsigned snapshot_count;
+	unsigned snap_count;
 
 	if (lv_is_thin_pool(lv)) {
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]) ||
@@ -286,10 +286,10 @@ static int _lv_type_list_thin(struct dm_pool *mem,
 	} else if (lv_is_thin_volume(lv)) {
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
-		if (lv_is_thin_origin(lv, &snapshot_count) &&
+		if (lv_is_thin_origin(lv, &snap_count) &&
 		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_ORIGIN]))
 				goto_bad;
-		if (snapshot_count > 1 &&
+		if (snap_count > 1 &&
 		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MULTIPLE]))
 			goto_bad;
 		if (first_seg(lv)->origin)


