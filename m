From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:43 +0000 (GMT)
Subject: main - cleanup: typo fix
Message-ID: <20210920132943.E4CBF3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0bbdfba7fa300cec657c8a1bac2af062bea3439
Commit:        a0bbdfba7fa300cec657c8a1bac2af062bea3439
Parent:        3817392d87f24c2d350f801daac2ee16358c1ecf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 17 22:42:41 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 17 22:42:41 2021 +0200

cleanup: typo fix

---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 7dc326d9f..5fda9db1e 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -310,7 +310,7 @@ convert2lvm_() {
 	case "$DM_OPEN" in
 	Device*) ;; # no devices
 	*)	eval "$DM_OPEN"
-		test "${DM_OPEN:-0}" -eq 0 || error "Cannot converted VDO volume \"$VDONAME\" which is in use!"
+		test "${DM_OPEN:-0}" -eq 0 || error "Cannot convert VDO volume \"$VDONAME\" which is in use!"
 		;;
 	esac
 


