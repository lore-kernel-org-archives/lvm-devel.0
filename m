From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 19:12:05 +0000 (UTC)
Subject: master - test: Fail devices silently in lvconvert-repair-transient.sh.
Message-ID: <20140608191205.B53F061200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f58a7f305bae83e678e0e46ba99c18d9ec580f81
Commit:        f58a7f305bae83e678e0e46ba99c18d9ec580f81
Parent:        eda4c3a41d7ca1642ee779af69cb862ba8332e66
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 26 14:38:46 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 21:10:47 2014 +0200

test: Fail devices silently in lvconvert-repair-transient.sh.

---
 test/shell/lvconvert-repair-transient.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 3614a69..21df1ef 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -14,12 +14,16 @@
 aux mirror_recovery_works || skip
 aux prepare_vg 5
 
+# ordinary mirrors
+
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
-aux disable_dev "$dev2" "$dev4"
+aux disable_dev --error --silent "$dev2" "$dev4"
 mkfs.ext3 "$DM_DEV_DIR/$vg/4way" &
 sleep 1
-aux enable_dev "$dev2" "$dev4"
+dmsetup status
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+aux enable_dev --silent "$dev2" "$dev4"
+
 lvs -a -o +devices | tee out
 not grep unknown out
 vgreduce --removemissing $vg


