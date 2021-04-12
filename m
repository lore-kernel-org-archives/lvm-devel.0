From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 08:48:07 +0000 (GMT)
Subject: main - tests: enable for 5.12+ kernels
Message-ID: <20210412084807.ACF8539F6C7A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=396d93937db940736675db13609640ac6856b912
Commit:        396d93937db940736675db13609640ac6856b912
Parent:        31410447fd5719368baf07ba34004330958fbcf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 12 10:47:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 10:47:06 2021 +0200

tests: enable for 5.12+ kernels

Should not longer kill kernel.
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 2dde4d014..1170e6567 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -72,7 +72,7 @@ check lv_first_seg_field $vg/$lv1 stripes 16
 
 # Reload table during reshape to test for data corruption
 case "$(uname -r)" in
-  5.[891]*|3.10.0-862*|4.18.0-*.el8*)
+  5.[89]*|5.1[01].*|3.10.0-862*|4.18.0-*.el8*)
 	should not echo "Skipping table reload test on on unfixed kernel!!!" ;;
   *)
 for i in {0..5}


