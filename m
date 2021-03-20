From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 20 Mar 2021 09:53:05 +0000 (GMT)
Subject: main - tests: add FIXME to raid test
Message-ID: <20210320095305.BCEA73858009@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=179f59a0ca7d4d5f779f86d990ebd336c9b13f0e
Commit:        179f59a0ca7d4d5f779f86d990ebd336c9b13f0e
Parent:        05920e3818b22c24dde59b3e562fe156466f83f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 10:39:02 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 10:52:24 2021 +0100

tests: add FIXME to raid test

We have here some kind of catch-22 - since older kernels do
use 'resync' while new 'recover' for initial raid synchronization.

So now - how do we recognize in which state of raid we are.
ATM seems to be simplest to simply keep disabled droping of primary raid
leg unless we are in sync.

FIXME: we should add a target version check and enable removal
---
 test/shell/lvconvert-raid.sh | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6aaaf3669..aa50fbb62 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -250,7 +250,13 @@ echo "Skippen test that kills this kernel"
 ;;
 *)
 lvconvert --yes -m 1 $vg/$lv1 "$dev3"
-lvconvert --yes -m 0 $vg/$lv1 "$dev1"
+
+# FIXME: it is unclear what should happen - older kernel
+# do use 'resync' for initial array building so then
+# we are not able to recognize difference
+# Should we check version target as react differentely ??
+# Otherwise we have problem with the above test case.
+should lvconvert --yes -m 0 $vg/$lv1 "$dev1"
 aux enable_dev "$dev2"
 ;;
 esac


