From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:42 +0000 (UTC)
Subject: master - tests: on older system use mirror type
Message-ID: <20140217212642.66C9E60520@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37cf2019063aa34cddf88ae3e2ee0f974f97b105
Commit:        37cf2019063aa34cddf88ae3e2ee0f974f97b105
Parent:        8eedb18c73f81de8682649afd21c996883c33e76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 15 13:28:16 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

tests: on older system use mirror type

---
 test/shell/lvchange-partial.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 891dd0a..4e508a9 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -11,11 +11,13 @@
 
 . lib/test
 
-aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_vg 4
 
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+TYPE=raid1
+aux target_at_least dm-raid 1 1 0 || TYPE=mirror
+
+lvcreate --type $TYPE -m 1 -l 2 -n $lv1 $vg
 lvchange -an $vg/$lv1
 aux disable_dev "$dev1"
 


