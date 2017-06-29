From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:52 -0400
Subject: master - blkdeactivate: quote literal
Message-ID: <201706292025.v5TKPqsP025732@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=daa372f78d316ded212ffd703a9740ff80632d38
Commit:        daa372f78d316ded212ffd703a9740ff80632d38
Parent:        b5fc0d73e551ed36c752e89b6f409935511f2ba4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 18:47:28 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: quote literal

This { is literal. Check expression (missing ;/\n?) or quote it.
---
 scripts/blkdeactivate.sh.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index a3528e5..969eace 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -242,7 +242,7 @@ deactivate_lvm () {
 		}
 
 		echo -n "  [LVM]: deactivating Logical Volume $DM_VG_NAME/$DM_LV_NAME... "
-		if eval "$LVM" lvchange $LVM_OPTS --config \'log{prefix=\"\"} $LVM_CONFIG\' -aln "$DM_VG_NAME/$DM_LV_NAME" "$OUT" "$ERR"; then
+		if eval "$LVM" lvchange $LVM_OPTS --config \'log\{prefix=\"\"\} $LVM_CONFIG\' -aln "$DM_VG_NAME/$DM_LV_NAME" "$OUT" "$ERR"; then
 			echo "done"
 		else
 			echo "skipping"
@@ -266,7 +266,7 @@ deactivate_lvm () {
 		done
 
 		echo -n "  [LVM]: deactivating Volume Group $DM_VG_NAME... "
-		if eval "$LVM" vgchange $LVM_OPTS --config \'log{prefix=\"    \"} $LVM_CONFIG\' -aln "$DM_VG_NAME" "$OUT" "$ERR"; then
+		if eval "$LVM" vgchange $LVM_OPTS --config \'log\{prefix=\"    \"\} $LVM_CONFIG\' -aln "$DM_VG_NAME" "$OUT" "$ERR"; then
 			echo "done"
 		else
 			echo "skipping"


