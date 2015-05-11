From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 14:15:03 +0000 (UTC)
Subject: master - tests: typo in aux
Message-ID: <20150511141503.067006138A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3eb2d4d2ce3c660fb5bd99c2093a00cb8f2fa4d5
Commit:        3eb2d4d2ce3c660fb5bd99c2093a00cb8f2fa4d5
Parent:        20e9ec35836fc4dd8064f40068e5be83dbf67bfa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 16:14:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 16:14:24 2015 +0200

tests: typo in aux

Ooops editor grabbed q in test.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0985767..ef25117 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -841,7 +841,7 @@ devices/cache_dir = "$TESTDIR/etc"
 devices/default_data_alignment = 1
 devices/dir = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
-qdevices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection  = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1


