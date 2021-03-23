From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 11:07:08 +0000 (GMT)
Subject: main - tests: ignore failure of zeroing
Message-ID: <20210323110708.7835E385EC54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=712f7dfb4cdb729609de230e41255c5af0526860
Commit:        712f7dfb4cdb729609de230e41255c5af0526860
Parent:        26d76d31c5251a35bc4be1c60a1066d13b1f5f1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 12:05:55 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 12:05:55 2021 +0100

tests: ignore failure of zeroing

Older mdadm fails the command, when the signature is already gone.
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 617d0b3a4..20736260f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -796,7 +796,7 @@ cleanup_md_dev() {
 	test "$DM_DEV_DIR" = "/dev" || rm -f "$(< MD_DEV_PV)"
 
 	for dev in $(< MD_DEVICES); do
-		mdadm --zero-superblock "$dev" 2>/dev/null
+		mdadm --zero-superblock "$dev" 2>/dev/null || true
 	done
 	udev_wait
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV


