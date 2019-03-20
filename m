From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:33 -0400
Subject: master - gitignore: update
Message-ID: <201903201339.x2KDdX3d012376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da31541bd8c6945158266f32a31842884e45a09b
Commit:        da31541bd8c6945158266f32a31842884e45a09b
Parent:        d84134c75bf2f5e9d289da73f68a57d43f5976c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 6 14:39:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:35:09 2019 +0100

gitignore: update

---
 .gitignore         |    9 +++++++++
 scripts/.gitignore |    3 +++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index f51bb67..7ebb8bb 100644
--- a/.gitignore
+++ b/.gitignore
@@ -25,17 +25,25 @@ make.tmpl
 
 /autom4te.cache/
 /autoscan.log
+/build/
+/config.cache
 /config.log
 /config.status
 /configure.scan
 /cscope.out
+/html/
+/reports/
 /tags
 /tmp/
 
+coverity/coverity_model.xml
 
 tools/man-generator
 tools/man-generator.c
 
+test/.lib-dir-stamp
+test/.tests-stamp
+test/lib/dmsecuretest
 test/lib/lvchange
 test/lib/lvconvert
 test/lib/lvcreate
@@ -60,6 +68,7 @@ test/lib/pvremove
 test/lib/pvresize
 test/lib/pvs
 test/lib/pvscan
+test/lib/securetest
 test/lib/vgcfgbackup
 test/lib/vgcfgrestore
 test/lib/vgchange
diff --git a/scripts/.gitignore b/scripts/.gitignore
index 314bdb5..eb97db0 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -24,3 +24,6 @@ lvm2_monitoring_systemd_red_hat.service
 lvm2_pvscan_systemd_red_hat at .service
 lvm2_tmpfiles_red_hat.conf
 lvmdump.sh
+lvm2-pvscan.service
+lvmlockd.service
+lvmlocks.service


