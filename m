From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Jan 2019 12:39:47 -0500
Subject: master - tests: use pvscan after enable_dev in process-each-duplicate-vgnames
Message-ID: <201901281739.x0SHdl8c031909@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbf62b9262d493a5df9ab5a57e68395465d4701a
Commit:        cbf62b9262d493a5df9ab5a57e68395465d4701a
Parent:        30ad845f3d140f6778775ae5fe901b5d7e4988bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 28 11:38:05 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 28 11:38:05 2019 -0600

tests: use pvscan after enable_dev in process-each-duplicate-vgnames

instead of vgscan, so that new dev is recognized with hints
---
 test/shell/process-each-duplicate-vgnames.sh |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index ea79c91..a59c3bd 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -20,20 +20,16 @@ pvcreate "$dev2"
 aux disable_dev "$dev1" "$dev2"
 
 aux enable_dev "$dev1"
-vgscan
 vgcreate $vg1 "$dev1"
 UUID1=$(vgs --noheading -o vg_uuid $vg1)
 aux disable_dev "$dev1"
 
 aux enable_dev "$dev2"
-vgscan
 vgcreate $vg1 "$dev2"
 UUID2=$(vgs --noheading -o vg_uuid $vg1)
 
 aux enable_dev "$dev1"
-# need vgscan after enabling/disabling devs
-# so that the next commands properly see them
-vgscan
+pvscan --cache "$dev1"
 pvs "$dev1"
 pvs "$dev2"
 
@@ -50,11 +46,10 @@ vgs -o+vg_uuid | tee err
 grep $UUID1 err
 not grep $UUID2 err
 aux enable_dev "$dev2"
-vgscan
+pvscan --cache "$dev2"
 
 aux disable_dev "$dev1"
 vgs -o+vg_uuid | tee err
 grep $UUID2 err
 not grep $UUID1 err
 aux enable_dev "$dev1"
-vgscan


