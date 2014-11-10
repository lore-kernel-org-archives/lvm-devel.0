From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:33:25 +0000 (UTC)
Subject: master - mirror: layer remove doesn't work properly with mirrors
Message-ID: <20141110213325.B74CE61026@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7fc1082987c3d5842664fd7817ec01e1ddec9cc
Commit:        a7fc1082987c3d5842664fd7817ec01e1ddec9cc
Parent:        094596cfd2001a8714923dd87abb2feacd116a13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 22:32:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:32:43 2014 +0100

mirror: layer remove doesn't work properly with mirrors

---
 lib/metadata/lv_manip.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 220f894..20bf76f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6007,14 +6007,15 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	 *   currently supported only for thin data layer
 	 *   FIXME: without strcmp it breaks mirrors....
 	 */
-	for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
-		if (strstr(layer_lv->name, _suffixes[r]) == 0) {
-			lv_names.old = layer_lv->name;
-			lv_names.new = parent_lv->name;
-			if (!for_each_sub_lv(parent_lv, _rename_cb, (void *) &lv_names))
-				return_0;
-			break;
-		}
+	if (!strstr(layer_lv->name, "_mimage"))
+		for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
+			if (strstr(layer_lv->name, _suffixes[r]) == 0) {
+				lv_names.old = layer_lv->name;
+				lv_names.new = parent_lv->name;
+				if (!for_each_sub_lv(parent_lv, _rename_cb, (void *) &lv_names))
+					return_0;
+				break;
+			}
 
 	return 1;
 }


