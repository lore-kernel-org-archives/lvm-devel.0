From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:32 +0000 (UTC)
Subject: master - libdm: select: recognize special selection string 'all' as an alias for blank selection string
Message-ID: <20160620094132.A7F2D60759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b93db65660c5dbb5b68d458ffa4c034a4c37211
Commit:        5b93db65660c5dbb5b68d458ffa4c034a4c37211
Parent:        1127b090bd07065a6a5046881ba1692bd507b9da
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 13 15:23:44 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

libdm: select: recognize special selection string 'all' as an alias for blank selection string

---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1772e18..8911e36 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Recognize 'all' keyword used in selection as synonym for "" (no selection).
   Add dm_report_set_selection to set selection for multiple output of report.
   Add DM_REPORT_OUTPUT_MULTIPLE_TIMES flag for multiple output of same report.
   Move field width handling/sort init from dm_report_object to dm_report_output.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index cae9c66..1326fdf 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3984,6 +3984,8 @@ static int _alloc_rh_selection(struct dm_report *rh)
 	return 1;
 }
 
+#define SPECIAL_SELECTION_ALL "all"
+
 static int _report_set_selection(struct dm_report *rh, const char *selection, int add_new_fields)
 {
 	struct selection_node *root = NULL;
@@ -3999,7 +4001,7 @@ static int _report_set_selection(struct dm_report *rh, const char *selection, in
 			goto_bad;
 	}
 
-	if (!selection)
+	if (!selection || !strcasecmp(selection, SPECIAL_SELECTION_ALL))
 		return 1;
 
 	rh->selection->add_new_fields = add_new_fields;


