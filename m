From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 13:55:41 +0000 (UTC)
Subject: master - tests: remove extra vgremove
Message-ID: <20140227135541.381BC60FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7dc422bde933d2c397f14334d74ae0abacbaccf
Commit:        a7dc422bde933d2c397f14334d74ae0abacbaccf
Parent:        c23cd12023bd18a83ae0f284e69f3b6689d79b37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 27 14:53:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 14:53:33 2014 +0100

tests: remove extra vgremove

These vgremove calls were not correct.
---
 test/shell/lvconvert-repair-thin.sh |    2 --
 test/shell/lvmetad-warning.sh       |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 37a24ff..b80b855 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -114,5 +114,3 @@ should vgremove -ff  $vg
 # Let's do a final forced cleanup
 pvremove --yes -ff "$dev3"
 pvremove --yes -ff "$dev4"
-
-vgremove -ff $vg
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 6953165..3fc4cf5 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -26,4 +26,4 @@ aux prepare_lvmetad
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
 
-vgremove -ff $vg
+vgremove -ff $vg1


