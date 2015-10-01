From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  1 Oct 2015 14:47:47 +0000 (UTC)
Subject: master - tests: ensure test will not block
Message-ID: <20151001144747.1D3AC60321@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c2cc782aa8c7e6bdc18339215f65e82ea1489ae
Commit:        4c2cc782aa8c7e6bdc18339215f65e82ea1489ae
Parent:        05e7fdd5ce3eb5db827aa8b8ab9e07571d9a857a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 1 16:45:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 1 16:45:14 2015 +0200

tests: ensure test will not block

This test is somewhat 'stupid' and simulates mostly unsupported
situation - so avoid blocking here.
---
 test/shell/snapshot-remove-dmsetup.sh |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 610d3c2..952a7bb 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -58,9 +58,17 @@ dmsetup resume $vg1-snap
 # Try how force removal works
 dmsetup suspend $vg-$lv1
 # needs to fail as device is still open
-not dmsetup remove --force $vg1-snap
+not dmsetup remove --force $vg1-snap &
+
+sleep .5
+
+dmsetup table $vg1-snap | tee out
+should grep -i error out
+
 dmsetup resume $vg-$lv1
 
+wait
+
 # check it really is now 'error' target
 dmsetup table $vg1-snap | tee out
 grep error out


