From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 16:35:18 +0000 (UTC)
Subject: master - tests: update lvcreate-thin for latest changes
Message-ID: <20140617163518.B9CE560D68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef43a50926d0590910798dd366f6b8da548b05a3
Commit:        ef43a50926d0590910798dd366f6b8da548b05a3
Parent:        d09590c4b601f261d164fd253c7f2b9864cbf7ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 17 18:19:59 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 18:20:08 2014 +0200

tests: update lvcreate-thin for latest changes

With recent changes introduced with the report selection support,
the content of lv_modules field is of string list type (before
it was just string type).

String list elements are always ordered now so update lvcreate-thin
test to expect the elements to be ordered.
---
 test/shell/lvcreate-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 9712652..215bfac 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -146,7 +146,7 @@ lvcreate --type snapshot $vg/lv1 --name lv4
 lvcreate --type snapshot $vg/lv1 --name $vg/lv5
 
 lvdisplay --maps $vg
-check_lv_field_modules_ thin-pool,thin lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
+check_lv_field_modules_ thin,thin-pool lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
 check vg_field $vg lv_count 8
 
 lvremove -ff $vg


