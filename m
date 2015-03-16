From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Mar 2015 14:06:43 +0000 (UTC)
Subject: master - tests: drop unused ""
Message-ID: <20150316140643.E693460F91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6a69af2d751c83e6c1e82005607448630ae7047
Commit:        e6a69af2d751c83e6c1e82005607448630ae7047
Parent:        05f23e77634b2ed3d7861511c07ed73a3bb6d096
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 13 11:39:55 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 13 12:12:54 2015 +0100

tests: drop unused ""

---
 test/shell/pv-range-overflow.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index 4caee02..f6b9622 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -15,7 +15,7 @@
 
 aux prepare_vg 2
 
-lvcreate -L4 -n"$lv" $vg
+lvcreate -L4 -n $lv $vg
 
 # Test for the bogus diagnostic reported in BZ 284771
 # http://bugzilla.redhat.com/284771.


