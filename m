From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 27 Jul 2015 12:19:17 +0000 (UTC)
Subject: master - gitignore: Update for in-place build.
Message-ID: <20150727121917.C65EE6061D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3934ade5a22367f31bb951ebb2a2cb1bfd326f8c
Commit:        3934ade5a22367f31bb951ebb2a2cb1bfd326f8c
Parent:        f4fa3e1a6be13b5d07a6102a642e0cac0d338e62
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 27 13:18:35 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 27 13:18:35 2015 +0100

gitignore: Update for in-place build.

---
 .gitignore                  |   11 +++++++----
 conf/.gitignore             |    4 ++++
 daemons/clvmd/.gitignore    |    1 +
 daemons/cmirrord/.gitignore |    1 +
 daemons/dmeventd/.gitignore |    1 +
 daemons/lvmetad/.gitignore  |    2 ++
 daemons/lvmlockd/.gitignore |    2 ++
 daemons/lvmpolld/.gitignore |    1 +
 lib/misc/.gitignore         |    1 +
 python/.gitignore           |    2 ++
 scripts/.gitignore          |   12 ++++++++++++
 tools/.gitignore            |    1 +
 udev/.gitignore             |    5 +++++
 13 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/.gitignore b/.gitignore
index 52663d4..19181c9 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,13 +1,16 @@
 *.5
+*.7
 *.8
 *.a
 *.d
 *.o
+*.orig
 *.pc
 *.pot
+*.rej
 *.so
 *.so.*
-*.swp
+*.sw*
 *~
 
 .export.sym
@@ -17,11 +20,11 @@
 Makefile
 make.tmpl
 
-configure.h
-version.h
-
 /autom4te.cache/
+/autoscan.log
 /config.log
 /config.status
+/configure.scan
 /cscope.out
+/tags
 /tmp/
diff --git a/conf/.gitignore b/conf/.gitignore
new file mode 100644
index 0000000..f505a49
--- /dev/null
+++ b/conf/.gitignore
@@ -0,0 +1,4 @@
+command_profile_template.profile
+example.conf
+lvmlocal.conf
+metadata_profile_template.profile
diff --git a/daemons/clvmd/.gitignore b/daemons/clvmd/.gitignore
new file mode 100644
index 0000000..816032f
--- /dev/null
+++ b/daemons/clvmd/.gitignore
@@ -0,0 +1 @@
+clvmd
diff --git a/daemons/cmirrord/.gitignore b/daemons/cmirrord/.gitignore
new file mode 100644
index 0000000..2711e77
--- /dev/null
+++ b/daemons/cmirrord/.gitignore
@@ -0,0 +1 @@
+cmirrord
diff --git a/daemons/dmeventd/.gitignore b/daemons/dmeventd/.gitignore
new file mode 100644
index 0000000..71cca4c
--- /dev/null
+++ b/daemons/dmeventd/.gitignore
@@ -0,0 +1 @@
+dmeventd
diff --git a/daemons/lvmetad/.gitignore b/daemons/lvmetad/.gitignore
new file mode 100644
index 0000000..773097e
--- /dev/null
+++ b/daemons/lvmetad/.gitignore
@@ -0,0 +1,2 @@
+lvmetad
+lvmetactl
diff --git a/daemons/lvmlockd/.gitignore b/daemons/lvmlockd/.gitignore
new file mode 100644
index 0000000..6ba6109
--- /dev/null
+++ b/daemons/lvmlockd/.gitignore
@@ -0,0 +1,2 @@
+lvmlockctl
+lvmlockd
diff --git a/daemons/lvmpolld/.gitignore b/daemons/lvmpolld/.gitignore
new file mode 100644
index 0000000..4ffad0a
--- /dev/null
+++ b/daemons/lvmpolld/.gitignore
@@ -0,0 +1 @@
+lvmpolld
diff --git a/lib/misc/.gitignore b/lib/misc/.gitignore
index 37a05fe..396884b 100644
--- a/lib/misc/.gitignore
+++ b/lib/misc/.gitignore
@@ -1 +1,2 @@
+configure.h
 lvm-version.h
diff --git a/python/.gitignore b/python/.gitignore
new file mode 100644
index 0000000..c87e43e
--- /dev/null
+++ b/python/.gitignore
@@ -0,0 +1,2 @@
+.liblvm_built
+setup.py
diff --git a/scripts/.gitignore b/scripts/.gitignore
index 2b9162d..3a668ae 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -1,12 +1,24 @@
+blk_availability_init_red_hat
+blk_availability_systemd_red_hat.service
+blkdeactivate.sh
 clvmd_init_red_hat
 cmirrord_init_red_hat
 dm_event_systemd_red_hat.service
+dm_event_systemd_red_hat.socket
+lvm2_activation_generator_systemd_red_hat
+lvm2_cluster_activation_red_hat.sh
+lvm2_cluster_activation_systemd_red_hat.service
+lvm2_clvmd_systemd_red_hat.service
+lvm2_cmirrord_systemd_red_hat.service
 lvm2_lvmetad_init_red_hat
 lvm2_lvmetad_systemd_red_hat.service
 lvm2_lvmetad_systemd_red_hat.socket
+lvm2_lvmlockd_systemd_red_hat.service
+lvm2_lvmlocking_systemd_red_hat.service
 lvm2_lvmpolld_init_red_hat
 lvm2_lvmpolld_systemd_red_hat.service
 lvm2_lvmpolld_systemd_red_hat.socket
 lvm2_monitoring_init_red_hat
 lvm2_monitoring_systemd_red_hat.service
+lvm2_pvscan_systemd_red_hat at .service
 lvm2_tmpfiles_red_hat.conf
diff --git a/tools/.gitignore b/tools/.gitignore
index d06b2d8..2e7b332 100644
--- a/tools/.gitignore
+++ b/tools/.gitignore
@@ -1,3 +1,4 @@
 .commands
 dmsetup
+dmstats
 lvm
diff --git a/udev/.gitignore b/udev/.gitignore
new file mode 100644
index 0000000..303d787
--- /dev/null
+++ b/udev/.gitignore
@@ -0,0 +1,5 @@
+10-dm.rules
+11-dm-lvm.rules
+13-dm-disk.rules
+69-dm-lvm-metad.rules
+95-dm-notify.rules


