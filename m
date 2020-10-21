From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Oct 2020 17:48:26 +0000 (GMT)
Subject: master - tests: writecache-misc disable with lvmlockd
Message-ID: <20201021174826.A3A6C3857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83d08185234748f1837436d83cbf6817180551fd
Commit:        83d08185234748f1837436d83cbf6817180551fd
Parent:        6be29e1179725bcee19ff263635bb2927ef928bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 12:47:28 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 12:47:28 2020 -0500

tests: writecache-misc disable with lvmlockd

in a shared vg pvmove requires a named lv
---
 test/shell/writecache-misc.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/writecache-misc.sh b/test/shell/writecache-misc.sh
index 4f4c125fb..75364e5b3 100644
--- a/test/shell/writecache-misc.sh
+++ b/test/shell/writecache-misc.sh
@@ -13,6 +13,7 @@
 # Test single lv cache options
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
@@ -48,7 +49,7 @@ dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 aux prepare_devs 4
 
-vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 
 #


