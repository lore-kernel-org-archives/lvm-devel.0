From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:57 +0000 (GMT)
Subject: main - cleanup: move code
Message-ID: <20210308144657.EB0FB3952DBE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64447e9d9b237bf7955a84ab028a0d9b552e6ac7
Commit:        64447e9d9b237bf7955a84ab028a0d9b552e6ac7
Parent:        e5456c259f928c6e08ceecbd107796392e66325f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 18:10:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

cleanup: move code

just evaluate later in code path.
---
 lib/activate/activate.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a56227118..ddad7c3f7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2049,12 +2049,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	/* Ignore origin_only unless LV is origin in both old and new metadata */
-	/* or LV is thin or thin pool volume */
-	if (!lv_is_thin_volume(lv) && !lv_is_thin_pool(lv) &&
-	    !(lv_is_origin(lv) && lv_is_origin(lv_pre)))
-		laopts->origin_only = 0;
-
 	if (test_mode()) {
 		_skip("Suspending %s%s.", display_lvname(lv),
 		      laopts->origin_only ? " origin without snapshots" : "");
@@ -2076,6 +2070,12 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	lv_calculate_readahead(lv, NULL);
 
+	/* Ignore origin_only unless LV is origin in both old and new metadata */
+	/* or LV is thin or thin pool volume */
+	if (!lv_is_thin_volume(lv) && !lv_is_thin_pool(lv) &&
+	    !(lv_is_origin(lv) && lv_is_origin(lv_pre)))
+		laopts->origin_only = 0;
+
 	/*
 	 * Preload devices for the LV.
 	 * If the PVMOVE LV is being removed, it's only present in the old


