From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:08 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - cleanup: fix last commit
Message-ID: <20140916153508.0EDF66027D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9216eedfe8189947c506041d8fc9e879fac6d58
Commit:        e9216eedfe8189947c506041d8fc9e879fac6d58
Parent:        2360ce3551f2989f1cc2af06c3d3a0a0f1429bce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 15 22:04:14 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 15 22:04:14 2014 +0100

cleanup: fix last commit

---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index c3d0b6a..3ac5165 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -287,7 +287,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (lv_is_mirrored(lv) && !seg_is_raid(seg)) {
+	if (!lv_is_mirrored(lv) && !seg_is_raid(seg)) {
 		log_error("Unable to resync %s.  It is not RAID or mirrored.",
 			  lv->name);
 		return 0;


