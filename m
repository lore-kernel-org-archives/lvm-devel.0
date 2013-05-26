From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 22:55:52 +0000 (UTC)
Subject: dev-mornfall-nix - test: Set up global_filter instead of just filter when testing.
Message-ID: <20130526225552.98D5460EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2936d9837dcf21a6452f624f396972e345d248e
Commit:        f2936d9837dcf21a6452f624f396972e345d248e
Parent:        9fe5889a0d9584ebdd898059bf9638d19279fc39
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 00:53:03 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 00:53:03 2013 +0200

test: Set up global_filter instead of just filter when testing.

---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 00e0da4..a59e785 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -475,7 +475,8 @@ lvmconf() {
             cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
-devices/filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+devices/filter = "a|.*|"
+devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
 devices/default_data_alignment = 1


