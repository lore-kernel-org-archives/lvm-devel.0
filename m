From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:58 +0000 (UTC)
Subject: master - debug: cut_and_paste type in message
Message-ID: <20160211173958.B98BA60A37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53058e523411d7ef09d9a934a48764fa9ad22b72
Commit:        53058e523411d7ef09d9a934a48764fa9ad22b72
Parent:        cc23fdbd13a616010e54fa0491f5de9cee340fec
Author:        M.H. Tsai <mingnus@gmail.com>
AuthorDate:    Wed Jan 27 19:11:03 2016 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:38:40 2016 +0100

debug: cut_and_paste type in message

Typo in debug message.
---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 61651bf..a7ac608 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1160,7 +1160,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin percent for LV %s.",
+	log_debug_activation("Checking thin-pool percent for LV %s.",
 			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))


