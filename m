From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 16 Feb 2015 14:33:20 +0000 (UTC)
Subject: master - NIX: Resolve issues with fedora-release and kernel-modules-extra.
Message-ID: <20150216143320.5A29C60EEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df28c4d912709667e743f5c9ab8974feeb37eafe
Commit:        df28c4d912709667e743f5c9ab8974feeb37eafe
Parent:        727c7ff85d448743f751bc5218e73c41314ed5f1
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 11 14:22:05 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Feb 16 15:32:01 2015 +0100

NIX: Resolve issues with fedora-release and kernel-modules-extra.

---
 nix/default.nix |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 08193c8..e0c9499 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -207,7 +207,7 @@ let
         };
         urlPrefix = centos_url version arch;
         archs = ["noarch" arch] ++ (if eqStrings arch "i386" then ["i586" "i686"] else []);
-        packages = [ "centos-release" ] ++ pkgs.vmTools.commonFedoraPackages;
+        packages = pkgs.vmTools.commonCentOSPackages;
       };
       fedora = { version, sha, arch }: rec {
         name = "fedora-${version}-${arch}";
@@ -218,7 +218,7 @@ let
         };
         urlPrefix = fedora_url version arch;
         archs = ["noarch" arch] ++ (if eqStrings arch "i386" then ["i586" "i686"] else []);
-        packages = [ "fedora-release" ] ++ pkgs.vmTools.commonFedoraPackages;
+        packages = pkgs.vmTools.commonFedoraPackages;
         unifiedSystemDir = true;
       };
       rawhide = version: arch: repodata: import (pkgs.runCommand "rawhide-${version}-${arch}.nix" {} ''
@@ -303,20 +303,19 @@ let
                  "perl-GD" # for lcov
                  "kernel"
                ];
-      fedora_common = [ "fedora-release" "dlm-devel" "corosynclib-devel" ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" ];
       centos64 = centos63;
       centos65 = centos64;
-      centos70 = fedora20;
+      centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
+                   "procps-ng" "valgrind-devel" ];
 
       fedora17 = fedora18 ++ [ "libudev-devel" ];
 
-      fedora18 = [ "fedora-release" "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
-                   "dlm" "systemd-devel" "perl-Digest-MD5" ];
+      fedora18 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
+                   "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
       fedora18u = fedora18;
 
-      fedora19 = [ "fedora-release" "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
-                   "procps-ng" "valgrind-devel" ];
+      fedora19 = centos70 + [ "kernel-modules-extra" ];
       fedora19u = fedora19;
 
       fedora20 = fedora19;


