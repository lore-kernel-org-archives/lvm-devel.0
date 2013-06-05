From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:36 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: do not expose duplicate PVs in vgimportclone.sh
Message-ID: <20130605120536.660756137B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c6f3006e742b738545e7c8d89f0c12b7eb436ec
Commit:        8c6f3006e742b738545e7c8d89f0c12b7eb436ec
Parent:        65a0650135bef9bae9ce3a168e9ab2a8d9b70673
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 14:48:45 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: do not expose duplicate PVs in vgimportclone.sh

---
 test/shell/vgimportclone.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 4b66f96..0c81585 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -21,8 +21,13 @@ dd if="$dev1" of="$dev2" bs=256K count=1
 aux notify_lvmetad "$dev2"
 
 # Verify pvs works on each device to give us vgname
+aux hide_dev $dev2
 check pv_field "$dev1" vg_name $vg1
+aux unhide_dev $dev2
+
+aux hide_dev $dev1
 check pv_field "$dev2" vg_name $vg1
+aux unhide_dev $dev1
 
 # Import the cloned PV to a new VG
 vgimportclone --basevgname $vg2 "$dev2"


