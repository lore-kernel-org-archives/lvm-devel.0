From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Aug 2017 14:56:43 +0200
Subject: [PATCHv2 2/2] tests: Test stripes option with RAID1
In-Reply-To: <1503406603-15068-1-git-send-email-mcsontos@redhat.com>
References: <1503406603-15068-1-git-send-email-mcsontos@redhat.com>
Message-ID: <1503406603-15068-3-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/lvconvert-raid.sh | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index c5e6159..70ebc530 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -100,6 +100,17 @@ done
 done
 
 ##############################################
+# RAID1 - stripes option not allowed
+##############################################
+lvcreate -aey -l 2 -n $lv1 $vg
+not lvconvert --type raid1 -y -m 1 --stripes 2 $vg/$lv1
+not lvconvert --type raid1 -y -m 1 --stripesize 64k $vg/$lv1
+not lvconvert --type raid1 -y -m 1 -I 64k $vg/$lv1
+# NOTE: -i is --interval not --stripe here!
+lvconvert --type raid1 -y -m 1 -i 2 $vg/$lv1
+lvremove -ff $vg
+
+##############################################
 # RAID1 - shouldn't be able to add image
 #         if created '--nosync', but should
 #         be able to after 'lvchange --resync'
-- 
1.8.3.1


