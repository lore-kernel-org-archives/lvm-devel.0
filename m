From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 09:00:37 -0400
Subject: master - spec: Remove unsupported config options
Message-ID: <201807241300.w6OD0bZ3017827@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7709b70f976a13b3428679679cded47d2d642f30
Commit:        7709b70f976a13b3428679679cded47d2d642f30
Parent:        86c3940537092cee3e1899e065bcc36ddc0236be
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 14:57:52 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 15:00:12 2018 +0200

spec: Remove unsupported config options

---
 spec/build.inc  |    3 ---
 spec/source.inc |    1 -
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index a630bb7..8067e58 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -3,16 +3,13 @@
 %with default-pid-dir %{_default_pid_dir}
 %with default-locking-dir %{_default_locking_dir}
 %with usrlibdir %{_libdir}
-%enableif 1 lvm1_fallback
 %enableif 1 fsadm
-%with pool internal
 %with user
 %with group
 %with device-uid 0
 %with device-gid 6
 %with device-mode 0660
 %enableif 1 pkgconfig
-%enableif 1 applib
 %enableif 1 cmdlib
 %enableif 1 dmeventd
 %enableif 1 write_install
diff --git a/spec/source.inc b/spec/source.inc
index b23e3b6..05eb9c2 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -30,7 +30,6 @@
 
 %global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
 %global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
-%with clvmd corosync
 
 # TODO %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
 %with cache internal


