From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:32 -0400
Subject: stable-2.02 - tests: be happy with less then 90 percent
Message-ID: <201911011526.xA1FQW17016408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=343d80a7fe883d84aaa27f0a6960a20fa20ce790
Commit:        343d80a7fe883d84aaa27f0a6960a20fa20ce790
Parent:        a611f24751839b6ed63b130a75e403ac139eede9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:21:52 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:21:52 2019 +0100

tests: be happy with less then 90 percent

Thin metadata evolve between kernel version, so it's not always
precisely predictible its usage - so let's met test happy,
when it gets bellow 90%.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 20b70d3..2f16d48 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -111,7 +111,10 @@ lvs -a $vg
 lvextend --use-policies --config "\
 activation/thin_pool_autoextend_percent=1 \
 activation/thin_pool_autoextend_threshold=99" $vg/pool
-test "$(meta_percent_)" -lt "88"
+# Originaly wanted to test <88% -
+#  however some older kernels consume a bit more space, so be happy
+#  when it's <90%
+test "$(meta_percent_)" -lt "90"
 
 # After such operatoin creation of thin LV has to pass
 lvcreate -V20 $vg/pool


