From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:26 +0000 (UTC)
Subject: master - tests: test spare volume removal
Message-ID: <20140317133326.97FC260EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=909e2207bd181141b423bc8b62992c761a0b8c35
Commit:        909e2207bd181141b423bc8b62992c761a0b8c35
Parent:        404593c710678082f7ff16efdfd1fe5394fb1bba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 16 23:47:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:44 2014 +0100

tests: test spare volume removal

---
 test/shell/lvcreate-thin.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index cfa605e..0873ce1 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -176,6 +176,9 @@ not lvcreate -L4M --chunksize 2G -T $vg/pool1
 # Test creation of inactive pool
 lvcreate -an -L4M -T $vg/pool1
 lvcreate -V2G --name lv1 -T $vg/pool1
+# Check we are able remove spare volume if we want to
+lvremove -f $vg/lvol0_pmspare
+
 # Origin name is not accepted
 not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
 


