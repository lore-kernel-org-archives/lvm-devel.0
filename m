From: Daniel Mierswa <impulze@impulze.org>
Date: Sat, 26 Sep 2009 17:33:47 +0200
Subject: [PATCH 3/3] adjust the testsuite to work with new output
In-Reply-To: <1253979227-28051-1-git-send-email-impulze@impulze.org>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
Message-ID: <1253979227-28051-3-git-send-email-impulze@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The last change made LVM tools print different size strings and the
testsuite needs to be adjusted to recognize those.

Signed-off-by: Daniel Mierswa <impulze@impulze.org>
---
 test/t-lvcreate-usage.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 741351d..4180a96 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -30,7 +30,7 @@ grep "^  Negative stripesize is invalid\$" err
 
 # 'lvcreate rejects a too-large stripesize'
 not lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err
-grep "^  Stripe size cannot be larger than 512.00 GB\$" err
+grep "^  Stripe size cannot be larger than 512.00 GiB\$" err
 
 # 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
 lvcreate -L 64M -n $lv -i1 --stripesize 4 $vg >out 2>err 
@@ -53,7 +53,7 @@ grep "^  Number of stripes (129) must be between 1 and 128\$" err
 # The case on lvdisplay output is to verify that the LV was not created.
 # 'lvcreate rejects an invalid stripe size'
 not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
-grep "^  Invalid stripe size 3\.00 KB\$" err
+grep "^  Invalid stripe size 3\.00 KiB\$" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
 # Setting max_lv works. (bz490298)
-- 
1.6.4.4


