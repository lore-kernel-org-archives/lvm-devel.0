From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:03:08 +0000 (UTC)
Subject: master - test: use global_filter with initial content
Message-ID: <20121012150308.1E61E2655@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9cc3f3acb47b698bb85dc24d3bfe890426c6d7b
Commit:        d9cc3f3acb47b698bb85dc24d3bfe890426c6d7b
Parent:        31d8c3ee856b3021f531bfcb92d71811d7e3d575
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 16:54:34 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:02:30 2012 +0200

test: use global_filter with initial content

---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4b56fb6..07326ec 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -410,7 +410,8 @@ lvmconf() {
             cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
-devices/filter = [ "a/dev\\\\/mirror/", "a/dev\\\\/mapper\\\\/.*pv[0-9_]*$/", "r/.*/" ]
+devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+devices/filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
 devices/default_data_alignment = 1


