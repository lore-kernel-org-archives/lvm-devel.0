From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:18 +0000 (GMT)
Subject: master - tests: check dmevent with bigger reserved_stack
Message-ID: <20201020203418.3E17D395182E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6be29e1179725bcee19ff263635bb2927ef928bc
Commit:        6be29e1179725bcee19ff263635bb2927ef928bc
Parent:        fdec4cd3e6fef08b76b410136156dbd487dad8d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 22:28:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:28:58 2020 +0200

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


