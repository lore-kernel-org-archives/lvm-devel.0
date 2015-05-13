From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 11:20:40 +0000 (UTC)
Subject: master - nix: more base packages
Message-ID: <20150513112040.4745960067@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=007ac0d36f2430a7a9048e2bc7f20cb5a204c413
Commit:        007ac0d36f2430a7a9048e2bc7f20cb5a204c413
Parent:        1b43d633688c5bc30cef8bc82f5db6a4fa1abeb6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 12 14:33:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 13 13:19:35 2015 +0200

nix: more base packages

---
 nix/default.nix |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index b1693af..6b0001e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -351,23 +351,25 @@ let
 
   install_rpms = rec {
       common = [ "libselinux-devel" "libsepol-devel" "ncurses-devel" "readline-devel"
-                 "valgrind" "gdb" "strace"
+                 "valgrind" "valgrind-devel" "gdb" "strace"
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
+                 "device-mapper-persistent-data" # thin and cache
+                 "sockat # used by test suite lvmpolld
                  "kernel"
                ];
-      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" "procps" ];
+      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "procps" ];
       centos64 = centos63 ++ [ "corosynclib-devel" ];
       centos65 = centos64;
       centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
-                   "device-mapper-persistent-data" "procps-ng" "valgrind-devel" ];
+                   "procps-ng" ];
 
       fedora17 = fedora18 ++ [ "libudev-devel" ];
 
-      fedora18 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
+      fedora18 = [ "dlm-devel" "corosynclib-devel"
                    "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
       fedora18u = fedora18;
 


