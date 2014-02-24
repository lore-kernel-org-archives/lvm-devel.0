From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:21 +0000 (UTC)
Subject: master - tests: drop mirror from filter
Message-ID: <20140224201721.0C39C609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8780e2d79596fcb3197e922247597d77336257e
Commit:        f8780e2d79596fcb3197e922247597d77336257e
Parent:        a920bc1a40f3d8d76d0109ecfc6559965b458986
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 00:24:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:36 2014 +0100

tests: drop mirror from filter

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7587c4b..66ed910 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -538,7 +538,7 @@ generate_config() {
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
-devices/global_filter = [ "a|$DM_DEV_DIR/mirror|", "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
 devices/default_data_alignment = 1


