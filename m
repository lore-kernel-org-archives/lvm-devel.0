From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Nov 2015 21:10:27 +0000 (UTC)
Subject: master - tests: allow lvmetad tests with duplicate VG names
Message-ID: <20151113211027.F3F1960EDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e425bce28132e4bad940fae5bfb1499d6a15391d
Commit:        e425bce28132e4bad940fae5bfb1499d6a15391d
Parent:        46193f4a59f30d69aa30c9af6aa68f8dec1e81b2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 13 15:09:26 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 13 15:09:26 2015 -0600

tests: allow lvmetad tests with duplicate VG names

---
 test/shell/process-each-duplicate-vgnames.sh |    1 -
 test/shell/vgrename-usage.sh                 |   12 ------------
 2 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 5cdf32b..90d3e23 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -7,7 +7,6 @@
 
 test_description='Test vgs with duplicate vg names'
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMETAD=1
 
 . lib/inittest
 
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 8893c0f..92070e8 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -41,18 +41,6 @@ vgcreate $vg2 "$dev2"
 not vgrename $vg1 $vg2
 vgremove $vg1 $vg2
 
-# FIXME: decide how lvmetad should handle
-# duplicate VG names.  lvmetad now ignores
-# the VG on device B if it already knows
-# about the same VG name on device A.
-# This lets you vgrename the VG on device A
-# which allows the VG on device B to reappear
-# once it's rescanned.
-# It's not yet known how we want lvmetad to
-# handle duplicate VG names.
-
-test -e LOCAL_LVMETAD && exit 0
-
 # vgrename duplicate name
 vgcreate $vg1 "$dev1"
 aux disable_dev "$dev1"


