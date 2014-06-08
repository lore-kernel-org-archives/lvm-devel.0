From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 19:12:08 +0000 (UTC)
Subject: master - test: Fix the vgck test after vg_write change.
Message-ID: <20140608191208.064A561200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60443d6a5d17c9f3ba935263a5e14a8548aab509
Commit:        60443d6a5d17c9f3ba935263a5e14a8548aab509
Parent:        f58a7f305bae83e678e0e46ba99c18d9ec580f81
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 20:16:13 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 21:10:47 2014 +0200

test: Fix the vgck test after vg_write change.

---
 test/shell/vgck.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 40af20a..b6858cb 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -18,11 +18,11 @@ dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 # TODO: aux lvmconf "global/locking_type = 4"
 
+vgscan 2>&1 | tee vgscan.out
+
 if test -e LOCAL_LVMETAD; then
-    vgscan 2>&1 | tee vgscan.out
     not grep "Inconsistent metadata found for VG $vg" vgscan.out
 else
-    not vgscan 2>&1 | tee vgscan.out
     grep "Inconsistent metadata found for VG $vg" vgscan.out
 fi
 


