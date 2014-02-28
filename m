From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 22:43:29 +0000 (UTC)
Subject: master - test: Fix stat calls in lvmetad-pvscan-filter.
Message-ID: <20140228224329.A21A860FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=daa897fe90d59c823af6c4b29c5b75fec5ad0be9
Commit:        daa897fe90d59c823af6c4b29c5b75fec5ad0be9
Parent:        1bb29bb402c24b7c0230e36b618ac5ce9c0ce822
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 23:33:30 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 23:33:30 2014 +0100

test: Fix stat calls in lvmetad-pvscan-filter.

---
 test/shell/lvmetad-pvscan-filter.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 5aed532..6ece577 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -15,8 +15,8 @@ test -e LOCAL_LVMETAD || skip
 
 aux prepare_pvs 2
 
-maj=$(($(stat --printf=0x%t "$dev2")))
-min=$(($(stat --printf=0x%T "$dev2")))
+maj=$(($(stat -L --printf=0x%t "$dev2")))
+min=$(($(stat -L --printf=0x%T "$dev2")))
 
 aux hide_dev $dev2
 not pvscan --cache $dev2 2>&1 | grep "not found"


