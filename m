From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 20 Sep 2012 05:40:42 +0000 (UTC)
Subject: master - cleanup: remove unused variable
Message-ID: <20120920054042.6606A2278@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17901569da5294322dcb09fd9b66531adabdf95d
Commit:        17901569da5294322dcb09fd9b66531adabdf95d
Parent:        9d0dc63c8bcf255eb48a236824b6e8a58026f305
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Sep 20 07:40:11 2012 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Sep 20 07:40:11 2012 +0200

cleanup: remove unused variable

---
 tools/lvchange.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5048cab..d1cb4cf 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -292,7 +292,6 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 
 static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
-	uint32_t s = 0;
 	struct cmd_context *cmd = seg->lv->vg->cmd;
 	struct lv_list *lvl, *tmp;
 


