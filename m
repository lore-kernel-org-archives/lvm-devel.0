From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:16 +0000 (UTC)
Subject: master - cleanup: use TARGET define
Message-ID: <20160331102216.027AF60DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b10253ab4d932565dc69e5b3b6715177bb593ba8
Commit:        b10253ab4d932565dc69e5b3b6715177bb593ba8
Parent:        86db143307effaa0f606e301ec6e1a8d8db5b716
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 30 10:15:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:21:40 2016 +0200

cleanup: use TARGET define

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 40e4086..de07f96 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1438,7 +1438,7 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "thin", 0,
+	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN, 0,
 		       (mapped) ? NULL : lv, percent, NULL, 1)))
 		return_0;
 


