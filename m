From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Sep 2022 12:59:05 +0000 (GMT)
Subject: main - tests: discard update
Message-ID: <20220921125905.A5FB53857BB8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96f303eb08d6429e92d727020788830a3f7fcfc8
Commit:        96f303eb08d6429e92d727020788830a3f7fcfc8
Parent:        cbfdb8735831412a7c87ce57c0ada5f1ee1c2358
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 12:52:08 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 14:58:34 2022 +0200

tests: discard update

---
 test/shell/lvchange-thin.sh | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index d9d261e4b..5c231030c 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -30,8 +30,12 @@ lvcreate -L10M -T $vg/pool
 # tests for checking thin-pool discard passdown are skipped
 pvmajor=$(get pv_field "$dev1" major)
 pvminor=$(get pv_field "$dev1" minor)
-test "$(< "/sys/dev/block/$pvmajor:$pvminor/queue/discard_granularity")" -ne 0 || \
-        no_discard=1
+
+if test "$(< "/sys/dev/block/$pvmajor:$pvminor/queue/discard_granularity")" -eq 0 ; then
+	no_discard=1
+else
+	no_discard=
+fi
 
 #
 # Check change operations on a thin-pool without any thin LV

