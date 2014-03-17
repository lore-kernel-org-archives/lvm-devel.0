From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:28 +0000 (UTC)
Subject: master - tests: skip mangling test
Message-ID: <20140317133328.AC8BE60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95f74af404411eff55f9e63dbb349adfac94dd59
Commit:        95f74af404411eff55f9e63dbb349adfac94dd59
Parent:        909e2207bd181141b423bc8b62992c761a0b8c35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 16 23:48:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:45 2014 +0100

tests: skip mangling test

Mangling is only using dmsetup commands,
so there is no lvm command and no contact with
clvmd nor lvmetad so skip this test there.
---
 test/shell/name-mangling.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index cf218fe..fe54de4 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -11,6 +11,11 @@
 
 . lib/test
 
+# This test is not using any lvm command
+# so skip duplicate CLMVD and lvmetad test
+test -e LOCAL_CLVMD && skip
+test -e LOCAL_LVMETAD && skip
+
 CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#+-.:=@_"
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
 FAIL_MULTI_STR="seems to be mangled more than once"


