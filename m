From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:41:53 +0000 (GMT)
Subject: main - cleanup: better wording
Message-ID: <20210920134153.B1E8A3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c0354fe0fc2f42ec35c57cc69444a825e5c5386
Commit:        4c0354fe0fc2f42ec35c57cc69444a825e5c5386
Parent:        1b5245199680841fd088cf1a834b3623b3ef18d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 15:41:14 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 15:41:14 2021 +0200

cleanup: better wording

Follow-up advice of native speaker.
---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 5fda9db1e..af7917b0c 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -310,7 +310,7 @@ convert2lvm_() {
 	case "$DM_OPEN" in
 	Device*) ;; # no devices
 	*)	eval "$DM_OPEN"
-		test "${DM_OPEN:-0}" -eq 0 || error "Cannot convert VDO volume \"$VDONAME\" which is in use!"
+		test "${DM_OPEN:-0}" -eq 0 || error "Cannot convert in use VDO volume \"$VDONAME\"!"
 		;;
 	esac
 


