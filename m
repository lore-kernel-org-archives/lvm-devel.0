From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 17:17:06 -0400
Subject: [PATCH] Fix t-inconsistent-metadata.sh.
In-Reply-To: <1246051026-2964-1-git-send-email-dwysocha@redhat.com>
References: <1246051026-2964-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1246051026-2964-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:25:10 CEST 2009  Petr Rockai <me@mornfall.net>
  * All tools now handle inconsistent metadata the same way.

Rebase 6/26/09

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-inconsistent-metadata.sh |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/test/t-inconsistent-metadata.sh b/test/t-inconsistent-metadata.sh
index f7785d4..fbbea15 100644
--- a/test/t-inconsistent-metadata.sh
+++ b/test/t-inconsistent-metadata.sh
@@ -40,23 +40,26 @@ vgscan 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgdisplay doesn't change anything
+# vgdisplay fixes
 init
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
 
 # lvs fixes up
 init
 lvs 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg - updating" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-not grep "Volume group $vg inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgs doesn't fix up... (why?)
+# vgs fixes up as well
 init
 vgs 2>&1 | tee cmd.out
-vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgs 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
-- 
1.6.0.6


