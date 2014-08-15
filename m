From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:46 +0000 (UTC)
Subject: master - cleanup: drop unneeded inits
Message-ID: <20140815130746.67F7661146@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bde4c19e65a823c9dc3a34606f2aefb76e41230
Commit:        1bde4c19e65a823c9dc3a34606f2aefb76e41230
Parent:        5095a6517da9b57b0d2540b961e9841ad02fa8cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 13 14:20:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

cleanup: drop unneeded inits

---
 tools/lvconvert.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d9fc749..7330c73 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3218,7 +3218,7 @@ static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *
 
 static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
-	struct logical_volume *lv = NULL;
+	struct logical_volume *lv;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
@@ -3265,8 +3265,8 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 				  void *handle)
 {
 	struct lvconvert_params *lp = handle;
-	const char *vg_name = NULL;
-	struct logical_volume *refreshed_lv = NULL;
+	const char *vg_name;
+	struct logical_volume *refreshed_lv;
 	int ret;
 
 	/*


