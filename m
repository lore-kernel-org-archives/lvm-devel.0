From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:35:57 +0000 (GMT)
Subject: main - vdo: lvm_import_vdo script needs to continue when vgname does not exist
Message-ID: <20210913103557.E71453858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9db4ddabc1cf912dee30e0e6293767f01c976a4a
Commit:        9db4ddabc1cf912dee30e0e6293767f01c976a4a
Parent:        bd2dae464386033241afa35934cdeddfe47f6a77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 18:10:13 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

vdo: lvm_import_vdo script needs to continue when vgname does not exist

When the script cannot find vgname - it needs to continue to run.
---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 39a320c84..a72056721 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -262,7 +262,7 @@ convert2lvm_() {
 			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
 				VGNAME=${DEFAULT_NAME%/*}
 				# Find largest matching VG name to our 'default' vgname
-				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "$VGNAME[0-9]? ?" | head -1)
+				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "$VGNAME[0-9]? ?" | head -1 || true)
 				if test -n "$LASTVGNAME" ; then
 					LASTVGNAME=${LASTVGNAME#*${VGNAME}}
 					# If the number is becoming too high, try some random number


