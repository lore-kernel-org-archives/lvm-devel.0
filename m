From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:53 +0000 (UTC)
Subject: master - tests: more pvresize tests
Message-ID: <20140325102353.A628D60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04861b9bed41a2e907fca6f71acbf4c39cfebfd5
Commit:        04861b9bed41a2e907fca6f71acbf4c39cfebfd5
Parent:        db04d3e6d29dde331a88eec2cec5249ee7c211f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 10:00:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:59 2014 +0100

tests: more pvresize tests

Maybe move to separate pvresize test,
remove vgck size this is already executed elsewhere.
---
 test/shell/covercmd.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index f1bdca9..ad7f480 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -77,7 +77,6 @@ for i in pr "p rw" an ay "-monitor y" "-monitor n" \
 done
 
 pvck "$dev1"
-vgck $vg
 vgs -o all $vg
 lvrename $vg $lv $lv-rename
 vgcfgbackup -f backup.$$ $vg
@@ -87,7 +86,12 @@ pvremove -y -ff "$dev5"
 not vgcfgrestore  -f backup.$$ $vg
 pvcreate -u $TEST_UUID --restorefile  backup.$$ "$dev5"
 vgremove -f $vg
+
+# test pvresize functionality
+not pvresize
+not pvresize --setphysicalvolumesize -10M "$dev1"
 pvresize --setphysicalvolumesize 10M "$dev1"
+pvresize "$dev1"
 
 # test various errors and obsoleted tools
 not lvmchange


