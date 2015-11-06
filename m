From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 Nov 2015 21:59:15 +0000 (UTC)
Subject: master - test: disable duplicate VG name test for lvmetad
Message-ID: <20151106215915.A118760356@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9341e36f1390c5aa4e79b2faee28a2aeabc64c5
Commit:        b9341e36f1390c5aa4e79b2faee28a2aeabc64c5
Parent:        8096f2224c0502a0cb56aaebd59d836daa677bc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 6 15:58:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 6 15:58:22 2015 -0600

test: disable duplicate VG name test for lvmetad

Until we decide how duplicate VG names should be
handled by lvmetad, and implement that.
---
 test/shell/vgrename-usage.sh |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 92070e8..8893c0f 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -41,6 +41,18 @@ vgcreate $vg2 "$dev2"
 not vgrename $vg1 $vg2
 vgremove $vg1 $vg2
 
+# FIXME: decide how lvmetad should handle
+# duplicate VG names.  lvmetad now ignores
+# the VG on device B if it already knows
+# about the same VG name on device A.
+# This lets you vgrename the VG on device A
+# which allows the VG on device B to reappear
+# once it's rescanned.
+# It's not yet known how we want lvmetad to
+# handle duplicate VG names.
+
+test -e LOCAL_LVMETAD && exit 0
+
 # vgrename duplicate name
 vgcreate $vg1 "$dev1"
 aux disable_dev "$dev1"


