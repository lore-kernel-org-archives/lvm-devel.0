From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:13 +0000 (UTC)
Subject: master - cleanup: debug message fix
Message-ID: <20160331102213.E348260DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86db143307effaa0f606e301ec6e1a8d8db5b716
Commit:        86db143307effaa0f606e301ec6e1a8d8db5b716
Parent:        fc7dacaa4c6bf0af4c5a457c098da26d7cc71f9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 29 15:57:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:21:25 2016 +0200

cleanup: debug message fix

Reported-by: Ming-Hung Tsai <mingnus gmail com>
---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2eb24d4..a3b2379 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1160,7 +1160,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin-pool percent for LV %s.",
+	log_debug_activation("Checking thin-pool transaction id for LV %s.",
 			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))


