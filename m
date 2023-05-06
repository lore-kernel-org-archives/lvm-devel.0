From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:21 +0000 (GMT)
Subject: main - tests: needs to be exported for tracing
Message-ID: <20230506204621.18E313858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cc5c2203b72e84b12cc93f2f73fb679f3f7ae09
Commit:        0cc5c2203b72e84b12cc93f2f73fb679f3f7ae09
Parent:        7267322fc19a6e09d6949058ee0efdb107e7ef81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 22:39:16 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:43:22 2023 +0200

tests: needs to be exported for tracing

---
 test/shell/lvresize-rounding.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index c2251eb06..52bedb4e8 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -36,7 +36,7 @@ lvresize -l+64 -i3 -I128 $vg/$lv1
 vgremove -f $vg
 
 # 15 extents
-LVM_TEST_AUX_TRACE=yes
+export LVM_TEST_AUX_TRACE=yes
 aux prepare_vg 3 22
 unset LVM_TEST_AUX_TRACE
 

