From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:11 +0000 (UTC)
Subject: dev-mornfall-activate - tests: missed skip in test
Message-ID: <20130604192811.6DA6A61434@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5f7d401e5e558ea7dffaa326a27dd432241e639
Commit:        c5f7d401e5e558ea7dffaa326a27dd432241e639
Parent:        db2b65704cb3e6d2b17dbc775017b36d8a23b5bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 21:58:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:58:51 2013 +0200

tests: missed skip in test

---
 test/shell/lvconvert-repair-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index f087f32..31d5116 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -12,12 +12,12 @@
 . lib/test
 
 test -e LOCAL_CLVMD && skip
+aux target_at_least dm-raid 1 1 0 || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 aux prepare_vg 8
-aux target_at_least dm-raid 1 1 0
 
 # RAID5 single replace
 lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"


