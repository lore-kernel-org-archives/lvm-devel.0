From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed,  2 Dec 2009 14:49:34 -0500
Subject: [PATCH 2/2] Add tests to check for readahead value in lvcreate.
In-Reply-To: <1259783374-16394-2-git-send-email-dwysocha@redhat.com>
References: <1259783374-16394-1-git-send-email-dwysocha@redhat.com>
	<1259783374-16394-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1259783374-16394-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-lvcreate-usage.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 14b6ecb..62cf151 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -125,3 +125,18 @@ lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvchange -a n $vg/$lv1
 lvremove $vg/$lv1
 lvremove -ff $vg
+
+# readahead default (auto), none, #, auto
+lvcreate -L 32m -n $lv $vg
+check_lv_field_ $vg/$lv lv_read_ahead "auto"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead none $vg
+check_lv_field_ $vg/$lv lv_read_ahead "0"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead 8k $vg
+check_lv_field_ $vg/$lv lv_read_ahead "8.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead auto $vg
+check_lv_field_ $vg/$lv lv_read_ahead "auto"
+lvremove -ff $vg
+
-- 
1.6.0.6


