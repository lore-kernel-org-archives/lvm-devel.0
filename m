From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 18 Oct 2013 14:34:21 +0000 (UTC)
Subject: master - TEST: Test was trying to kill 2 devices in RAID5 instead of RAID6
Message-ID: <20131018143421.699B960DD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7763607f3617188906dae9e9ae218e9099f5e6e9
Commit:        7763607f3617188906dae9e9ae218e9099f5e6e9
Parent:        546db1c4be55d47d41082a345e15a35055223154
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Oct 18 09:33:37 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Oct 18 09:33:37 2013 -0500

TEST: Test was trying to kill 2 devices in RAID5 instead of RAID6

Segment type being used for test should have been 'raid6'.
---
 test/shell/lvconvert-repair-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 84e247d..71c84c1 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -29,7 +29,7 @@ vgextend $vg "$dev3"
 lvremove -ff $vg
 
 # RAID6 double replace
-lvcreate --type raid5 -i 3 -l 2 -n $lv1 $vg \
+lvcreate --type raid6 -i 3 -l 2 -n $lv1 $vg \
     "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev4" "$dev5"


