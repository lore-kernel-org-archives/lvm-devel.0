From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  8 Aug 2016 17:44:07 +0000 (UTC)
Subject: master - test: Drop --mirrorlog when not a mirror.
Message-ID: <20160808174407.5788E60756@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=175e0905d5e18fe0f3c6f00cdd0eefcefe8eaa3a
Commit:        175e0905d5e18fe0f3c6f00cdd0eefcefe8eaa3a
Parent:        fc93085c7a7716671c3567d367dd2c75544a058b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 8 18:43:54 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 8 18:43:54 2016 +0100

test: Drop --mirrorlog when not a mirror.

---
 test/shell/lvconvert-mirror-basic.sh |   10 +++++++++-
 tools/lvconvert.c                    |    6 +++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 530e6dd..81fb0c6 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -97,7 +97,15 @@ test_lvconvert() {
 		alloc="--alloc anywhere"
 	fi
 
-	lvconvert --type mirror -m $finish_count --mirrorlog $finish_log_type \
+	# --mirrorlog is invalid with -m0
+	if [ "$finish_count" -eq 0 ]; then
+		mirrorlog=""
+		finish_log_type=""
+	else
+		mirrorlog="--mirrorlog"
+	fi
+
+	lvconvert --type mirror -m $finish_count $mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
 	test $active || lvchange -aey $vg/$lv1
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8dc9f6d..7c014e0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1700,8 +1700,8 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_mimage_count;
 	uint32_t new_log_count;
 
-	if (*lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
-		log_error("--corelog and --mirrorlog is only compatible with --type mirror");
+	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
+		log_error("--corelog and --mirrorlog are only compatible with mirror devices");
 		return 0;
 	}
 
@@ -1894,7 +1894,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 	if ((lp->corelog || lp->mirrorlog) && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
-		log_error("--corelog and --mirrorlog is only compatible with --type mirror");
+		log_error("--corelog and --mirrorlog are only compatible with mirror devices");
 		return 0;
 	}
 


