From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Jan 2018 05:46:26 -0500
Subject: master - python: some LVs do need exclusive activation
Message-ID: <201801231046.w0NAkQS4026871@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ee105089a261f5db2ba8b93c30708ba66dd1a01
Commit:        2ee105089a261f5db2ba8b93c30708ba66dd1a01
Parent:        9194610f42901c88a3393b679afabbdca7145268
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 22 11:39:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 23 11:45:18 2018 +0100

python: some LVs do need exclusive activation

---
 liblvm/lvm_lv.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 20ceda3..e5a35c4 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -304,7 +304,9 @@ static int _lvm_lv_activate(lv_t lv)
 		return -1;
 	}
 
-	if (lv_is_origin(lv)) {
+	if (lv_is_origin(lv) ||
+	    lv_is_pvmove(lv) ||
+	    seg_only_exclusive(first_seg(lv))) {
 		log_verbose("Activating logical volume \"%s\" "
 			    "exclusively", lv->name);
 		if (!activate_lv_excl(lv->vg->cmd, lv)) {


