From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 12:50:00 +0000 (UTC)
Subject: dev-mornfall-nix - test: Do not expose duplicate PVs in vgimportclone.sh.
Message-ID: <20130527125000.5ECCF60DCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2412716f1726aefcc57be3e2d8ca6f6f8b15b743
Commit:        2412716f1726aefcc57be3e2d8ca6f6f8b15b743
Parent:        20928cc3c0794be14e2da5108f64292764de55d2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 14:48:45 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 14:48:45 2013 +0200

test: Do not expose duplicate PVs in vgimportclone.sh.

---
 test/shell/vgimportclone.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 60c833a..b251249 100644
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


