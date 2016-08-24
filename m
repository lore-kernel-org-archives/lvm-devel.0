From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 24 Aug 2016 23:37:58 +0000 (UTC)
Subject: master - test: delay writes to all test PVs in lvchange-rebuild-raid.sh to avoid race
Message-ID: <20160824233759.B272260EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0e07d516eab26699b824d5d499a8662e1ab2152
Commit:        b0e07d516eab26699b824d5d499a8662e1ab2152
Parent:        7ba77681116ce702dc31827ca6d3db6bfd56a269
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Aug 25 01:36:13 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 25 01:37:34 2016 +0200

test: delay writes to all test PVs in lvchange-rebuild-raid.sh to avoid race

---
 test/shell/lvchange-rebuild-raid.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 4c36836..2c04549 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -19,7 +19,10 @@ aux have_raid 1 3 2 || skip
 aux prepare_vg 8
 
 # Delay 1st leg so that rebuilding status characters can be read
-aux delay_dev "$dev1" 0 3
+for d in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8"
+do
+	aux delay_dev $d 0 3
+done
 
 # rhbz 1064592
 


