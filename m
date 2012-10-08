From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  8 Oct 2012 05:23:52 +0000 (UTC)
Subject: master - TEST: Only run the pvscan --cache test with lvmetad active.
Message-ID: <20121008052352.AD696231A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dfafd77d4c5682ac9ee37f3a2a4dce92659187c
Commit:        0dfafd77d4c5682ac9ee37f3a2a4dce92659187c
Parent:        e7020732354eef05e3e1bda9c5bdf49788e49130
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 07:23:13 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 07:23:13 2012 +0200

TEST: Only run the pvscan --cache test with lvmetad active.

---
 test/shell/lvmetad-pvscan-cache.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index be95b38..a27b6ad 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -11,6 +11,8 @@
 
 . lib/test
 
+test -e LOCAL_LVMETAD || skip
+
 aux prepare_pvs 2
 
 vgcreate $vg1 $dev1 $dev2


