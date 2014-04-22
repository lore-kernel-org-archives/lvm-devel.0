From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 22 Apr 2014 10:54:52 +0000 (UTC)
Subject: master - test: add lvresize tests
Message-ID: <20140422105452.6725261039@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=795944f178c233ac3f638574de704322f130078a
Commit:        795944f178c233ac3f638574de704322f130078a
Parent:        7a1777302ff21bbc7cd81a1141f9c88c8fac2511
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Apr 22 12:47:14 2014 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Apr 22 12:53:30 2014 +0200

test: add lvresize tests

- test for Bug 1088153
- test lvextend does not reduce nor lvreduce extend LV
---
 test/shell/lvresize-usage.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 84431ed..65f6b1e 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -24,3 +24,14 @@ not lvresize -v -l +4 xxx/$lv
 ESIZE=$(get vg_field $vg vg_extent_size --units b)
 lvextend -L+64m -i 2 -I$(( ${ESIZE%%B} * 2 ))B $vg/$lv 2>&1 | tee err
 grep "Reducing stripe size" err
+
+lvremove -ff $vg
+
+lvcreate -L 10M -n lv $vg $dev1
+lvextend -L +10M $vg/lv $dev2
+
+# Attempt to reduce with lvextend and vice versa:
+not lvextend -L 16M $vg/lv
+not lvreduce -L 32M $vg/lv
+
+lvremove -ff $vg


