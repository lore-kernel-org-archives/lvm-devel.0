From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:12 +0000 (GMT)
Subject: stable-2.02 - tests: check dmevent with bigger reserved_stack
Message-ID: <20201020212512.3F6103951832@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df9eba82632d5ce0eaf267b412160e9b9c4c03e9
Commit:        df9eba82632d5ce0eaf267b412160e9b9c4c03e9
Parent:        9690193ce08854c56663bcbbe7da4c720c78be07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 22:28:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:50:05 2020 +0200

tests: check dmevent with bigger reserved_stack

Check dmeventd remains working when reserved_stack
is above 300KiB.
---
 test/shell/lvextend-thin-data-dmeventd.sh | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
index 7dfec4acc..7d37f16b3 100644
--- a/test/shell/lvextend-thin-data-dmeventd.sh
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -30,10 +30,13 @@ test_equal_() {
 
 aux have_thin 1 10 0 || skip
 
-aux prepare_dmeventd
-
+# set reserved stack size above dmeventd 300KiB stack
+# ATM such value should be simply ignored
 aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
-	    "activation/thin_pool_autoextend_threshold = 75"
+	    "activation/thin_pool_autoextend_threshold = 75" \
+	    "activation/reserved_stack = 512"
+
+aux prepare_dmeventd
 
 aux prepare_pvs 3 256
 get_devs


