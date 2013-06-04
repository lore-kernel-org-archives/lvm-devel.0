From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:40 +0000 (UTC)
Subject: master - tests: update test
Message-ID: <20130604135840.A8E9261043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0f995050f04f075eda9025db514be08b13c9a6e
Commit:        c0f995050f04f075eda9025db514be08b13c9a6e
Parent:        c8dda314666437852ffcd515e60433c66702a36e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 4 10:37:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:33 2013 +0200

tests: update test

Fix !test -> test !
---
 test/shell/inconsistent-metadata.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 9f4ffd2..4894861 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -43,7 +43,7 @@ not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
 # only vgscan would have noticed metadata inconsistencies when lvmetad is active
-if !test -e LOCAL_LVMETAD; then
+if test ! -e LOCAL_LVMETAD; then
 	# vgdisplay fixes
 	init
 	vgdisplay $vg 2>&1 | tee cmd.out
@@ -77,4 +77,5 @@ aux backup_dev "$dev2"
 vgcreate $vg "$dev1"
 vgextend $vg "$dev2"
 aux restore_dev "$dev2"
+vgscan $cache
 should check compare_fields vgs $vg vg_mda_count pvs "$dev2" vg_mda_count


