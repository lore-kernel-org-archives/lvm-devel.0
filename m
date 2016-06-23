From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:02:04 +0000 (UTC)
Subject: master - cleanup: drop setting lv_name
Message-ID: <20160623130204.3E2F860975@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83d483269de367facc14eee9072b79ffabdcaf82
Commit:        83d483269de367facc14eee9072b79ffabdcaf82
Parent:        e5b7ebcddabb885dd8a2f4cb5b5a0a32af834076
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 15 14:55:37 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:29 2016 +0200

cleanup: drop setting lv_name

lv_name arg is only used without known LV for resolving '*lv'.
Once we know *lv, never use  lv_name ever again.

So setting it when passing *lv has not needed.
---
 lib/locking/lvmlockd.c |    1 -
 liblvm/lvm_lv.c        |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f9d215a..e025428 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -367,7 +367,6 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct logical_volume *lv = vg->sanlock_lv;
 	struct lvresize_params lp = {
-		.lv_name = vg->sanlock_lv->name,
 		.sign = SIGN_NONE,
 		.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE),
 		.percent = PERCENT_NONE,
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index ccdc340..05dd482 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -457,7 +457,6 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	int rc = 0;
 	struct lvresize_params lp = {
-		.lv_name = lv->name,
 		.sign = SIGN_NONE,
 		.percent = PERCENT_NONE,
 		.resize = LV_ANY,


