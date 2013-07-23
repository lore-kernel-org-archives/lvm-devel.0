From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:58:56 +0000 (UTC)
Subject: master - cleanup: add explicit cast to proper enum type
Message-ID: <20130723125856.084D060E1D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0856393c8a1c622871b07fb452fbbd7c0da537a
Commit:        e0856393c8a1c622871b07fb452fbbd7c0da537a
Parent:        9b1834f075daf0fb3f349356a31c1bfed421384a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 23 10:46:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 23 14:53:29 2013 +0200

cleanup: add explicit cast to proper enum type

---
 liblvm/lvm_lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7fc2392..46399e4 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -443,7 +443,7 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 
 	if (lvcp) {
 		lvcp->vg = vg;
-		lvcp->lvp.discards = discard;
+		lvcp->lvp.discards = (thin_discards_t) discard;
 
 		if (chunk_size)
 			lvcp->lvp.chunk_size = chunk_size;


