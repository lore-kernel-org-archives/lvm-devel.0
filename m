From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:23 +0000 (UTC)
Subject: dev-mornfall-activate - tests: set up global_filter instead of just filter
Message-ID: <20130604192823.EA4AA60F8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28160cb04a0f7c89854eccb5ed8431b33ecc9d2a
Commit:        28160cb04a0f7c89854eccb5ed8431b33ecc9d2a
Parent:        e4cb88009ac05654ffdb011e3a11fd80bfbe283e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 00:53:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: set up global_filter instead of just filter

For testing setup global_filter.
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d09e1b7..0894a66 100644
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


