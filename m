From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 28 Mar 2014 16:08:22 +0000 (UTC)
Subject: master - tests: update pvs test
Message-ID: <20140328160822.5959860AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5aa2e5ec8c8fcb279362c73983f09b4b50f706c0
Commit:        5aa2e5ec8c8fcb279362c73983f09b4b50f706c0
Parent:        3181dc72e7fbca5a63a3fd077fce3eafa0808ac9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 17:06:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 17:06:13 2014 +0100

tests: update pvs test

TODO:
It seems commit 7e685e6c70e5b738e5740b920e6080b9a13c2556
has changed the old logic, when  'pvs device_name' used
to work. (regression from 2.02.104)
Currently put in extra pvscan.
---
 test/shell/lvmcache-exercise.sh |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 1e4b86a..785ab17 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -18,11 +18,16 @@ vgcreate $vg2 "$dev3" "$dev4" "$dev5"
 
 aux disable_dev "$dev1"
 pvscan
-vgcreate $vg1 "$dev2"
-aux enable_dev "$dev1"
 # dev1 is missing
 fail pvs $(cat DEVICES)
 
+vgcreate $vg1 "$dev2"
+aux enable_dev "$dev1"
+
+pvscan
+# FIXME: above pvscan should not be needed
+pvs "$dev1"
+
 # reappearing device (rhbz 995440)
 lvcreate -aey -m2 --type mirror -l4 --alloc anywhere --corelog -n $lv1 $vg2
 


