From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Aug 2014 12:38:20 +0000 (UTC)
Subject: master - tests: proper /dev access
Message-ID: <20140820123820.071B560080@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=473a4a65485d881edfb2220a2e8f3d4fbf228818
Commit:        473a4a65485d881edfb2220a2e8f3d4fbf228818
Parent:        8d00499167f010b82ea6ddebcc6b22ec170002f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 20 14:35:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 20 14:37:41 2014 +0200

tests: proper /dev access

Commit 5ebff6cc9f631b7409d99b72fa0b39ccec30bf1f seemed to introduce
new 'for' loop but the mode is not yet used.
But the access to /dev dir needs to go through $DM_DEV_DIR
and whole path needs to be in "".
---
 test/shell/pvmove-restart.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index f480aaa..dde7308 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -39,8 +39,9 @@ kill -9 $PVMOVE
 wait
 
 # Simulate reboot - forcibly remove related devices
+dmsetup table
 dmsetup remove $vg-$lv1
-dmsetup remove /dev/mapper/$vg-pvmove0*
+dmsetup remove "$DM_DEV_DIR/mapper/$vg-pvmove0*"
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


