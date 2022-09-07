From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:55 +0000 (GMT)
Subject: main - tests: remove slash
Message-ID: <20220907130455.1E3C83858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6e47a161240e977bac5522d85e92fff3c1c9026
Commit:        a6e47a161240e977bac5522d85e92fff3c1c9026
Parent:        8a92a526a0bd4f5c9f89a535ee8904143441f38e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 13:26:30 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: remove slash

---
 test/shell/lvchange-thin.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 992ed7145..d9d261e4b 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -30,7 +30,7 @@ lvcreate -L10M -T $vg/pool
 # tests for checking thin-pool discard passdown are skipped
 pvmajor=$(get pv_field "$dev1" major)
 pvminor=$(get pv_field "$dev1" minor)
-test "$(< "/sys/dev/block/$pvmajor\:$pvminor/queue/discard_granularity")" -ne 0 || \
+test "$(< "/sys/dev/block/$pvmajor:$pvminor/queue/discard_granularity")" -ne 0 || \
         no_discard=1
 
 #

