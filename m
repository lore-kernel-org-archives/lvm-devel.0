From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:39:49 -0500
Subject: master - test: cleanup command
Message-ID: <201712011739.vB1Hdn0p027208@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16fa9d9ed5569ac6b8f87375c2902de8280eefe4
Commit:        16fa9d9ed5569ac6b8f87375c2902de8280eefe4
Parent:        4daad1cf11d9bb16ff6d8f3adc0918cbacfbe398
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:39:38 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:39:38 2017 +0100

test: cleanup command

---
 test/shell/lvchange-partial-raid10.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 83193b2..caec3a3 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -26,7 +26,7 @@ lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
 lvchange -an $vg/$lv1
 aux disable_dev "$dev1" "$dev3"
-lvchange -ay $vg/$lv1 --partial
+lvchange -ay --partial $vg/$lv1
 lvchange -an $vg/$lv1
 
 aux enable_dev "$dev1"


