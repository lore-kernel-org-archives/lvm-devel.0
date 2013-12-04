From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 08:38:09 +0000 (UTC)
Subject: master - tests: one LV should be active and one inactive in covercmd test
Message-ID: <20131204083809.05D4460EFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=163666e513848e5d43d3e4f2f91b42d1a8f483a0
Commit:        163666e513848e5d43d3e4f2f91b42d1a8f483a0
Parent:        7b65363bf781cd58d45e2d9f12fdfed59b9dee55
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 4 09:37:32 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 09:38:00 2013 +0100

tests: one LV should be active and one inactive in covercmd test

---
 test/shell/covercmd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 59500d6..7a24a9c 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -112,7 +112,7 @@ lvcreate -l1 $vg1
 # at least one LV active - VG considered active
 vgcreate $vg2 $dev2
 lvcreate -l1 $vg2
-lvcreate -l1 $vg2
+lvcreate -l1 -an -Zn $vg2
 
 # no LVs active - VG considered inactive
 vgcreate $vg3 $dev3


