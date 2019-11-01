From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:26 -0400
Subject: stable-2.02 - tests: larger are needs to be disabled
Message-ID: <201911011526.xA1FQQA1016392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a611f24751839b6ed63b130a75e403ac139eede9
Commit:        a611f24751839b6ed63b130a75e403ac139eede9
Parent:        4ae481bb301d8c8b3a8ea3725a0ae57f3d7bca5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:11:01 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:12:39 2019 +0100

tests: larger are needs to be disabled

Since we 'disable' lvmetad via --repair of 'raid'
if such target is not present, we simply skip
all tests expecting disabled lvmetad.
---
 test/shell/lvmetad-disabled.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 389d191..0a9f44c 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -62,7 +62,6 @@ if aux have_raid 1 7 0 ; then
 lvcreate --type raid1 -m1 --nosync -l1 --alloc anywhere -n $lv2 $vg1
 lvconvert -y --repair $vg1/$lv2 2>&1 | tee out
 grep "WARNING: Disabling lvmetad cache" out
-fi
 
 pvs  -vvvv 2>&1 | tee out
 grep "$dev1" out
@@ -80,6 +79,7 @@ grep "WARNING: Not using lvmetad" out
 
 pvremove "$dev1" 2>&1 | tee out
 grep "WARNING: Not using lvmetad" out
+fi
 
 pvscan --cache  2>&1 | tee out
 not grep "WARNING: Disabling lvmetad cache" out


