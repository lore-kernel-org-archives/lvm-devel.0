From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:34 +0000 (GMT)
Subject: dev-next - git: update .gitignore
Message-ID: <20210322153934.A80EF385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81d3639955f0553d691e304dcc0b2eaaf6f24bb6
Commit:        81d3639955f0553d691e304dcc0b2eaaf6f24bb6
Parent:        d3d28b1b64ff6b89ac5150787f694e1db1794a1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 23:14:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:21:18 2021 +0100

git: update .gitignore

Hide some files from older builds.
---
 .gitignore         | 1 +
 include/.gitignore | 2 ++
 scripts/.gitignore | 5 +++--
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/.gitignore b/.gitignore
index 97a2a9b4b..8c1672bd2 100644
--- a/.gitignore
+++ b/.gitignore
@@ -32,6 +32,7 @@ make.tmpl
 /configure.scan
 /cscope.*
 /html/
+/python/
 /reports/
 /tags
 /tmp/
diff --git a/include/.gitignore b/include/.gitignore
index 424c745c1..110b82abb 100644
--- a/include/.gitignore
+++ b/include/.gitignore
@@ -1 +1,3 @@
 *.h
+.symlinks
+.symlinks_created
diff --git a/scripts/.gitignore b/scripts/.gitignore
index eb97db088..9cbadef58 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -1,11 +1,12 @@
+blkdeactivate.sh
 blk_availability_init_red_hat
 blk_availability_systemd_red_hat.service
-blkdeactivate.sh
 clvmd_init_red_hat
 cmirrord_init_red_hat
 com.redhat.lvmdbus1.service
 dm_event_systemd_red_hat.service
 dm_event_systemd_red_hat.socket
+lvm2-pvscan.service
 lvm2_activation_generator_systemd_red_hat
 lvm2_cluster_activation_red_hat.sh
 lvm2_cluster_activation_systemd_red_hat.service
@@ -16,6 +17,7 @@ lvm2_lvmetad_init_red_hat
 lvm2_lvmetad_systemd_red_hat.service
 lvm2_lvmetad_systemd_red_hat.socket
 lvm2_lvmlockd_systemd_red_hat.service
+lvm2_lvmlocking_systemd_red_hat.service
 lvm2_lvmpolld_init_red_hat
 lvm2_lvmpolld_systemd_red_hat.service
 lvm2_lvmpolld_systemd_red_hat.socket
@@ -24,6 +26,5 @@ lvm2_monitoring_systemd_red_hat.service
 lvm2_pvscan_systemd_red_hat at .service
 lvm2_tmpfiles_red_hat.conf
 lvmdump.sh
-lvm2-pvscan.service
 lvmlockd.service
 lvmlocks.service


