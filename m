From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:41 -0400
Subject: master - blkdeactivate: drop unused var
Message-ID: <201706292025.v5TKPfvv025695@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce1383fe46d2b830a89acaa9fe00fb1239be4969
Commit:        ce1383fe46d2b830a89acaa9fe00fb1239be4969
Parent:        45861557b5b531f828f4d6ed3d0b104144d2d5f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 19:36:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: drop unused var

---
 scripts/blkdeactivate.sh.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index a497414..69f02b0 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -221,7 +221,7 @@ deactivate_dm () {
 }
 
 deactivate_lvm () {
-	local DM_VG_NAME; local DM_LV_NAME; local DM_LV_LAYER
+	local DM_VG_NAME; local DM_LV_NAME
 
 	eval "$(eval "$DMSETUP" splitname --nameprefixes --noheadings --rows "$name" LVM "$ERR")"
 	test -b "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || return 0


