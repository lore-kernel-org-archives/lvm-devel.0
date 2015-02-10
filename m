From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 10 Feb 2015 16:27:50 +0000 (UTC)
Subject: master - NIX: Adjust lists of extra RPMs to install.
Message-ID: <20150210162750.DEEB760973@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79dc8f5ddd89fd54897347167163c5176b6f7511
Commit:        79dc8f5ddd89fd54897347167163c5176b6f7511
Parent:        a8b45b7a4c512137be1c919b6d247e2fe889edb4
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 10 17:26:02 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Feb 10 17:27:10 2015 +0100

NIX: Adjust lists of extra RPMs to install.

---
 nix/default.nix |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 0a45bab..919e9c9 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -303,26 +303,25 @@ let
                  "perl-GD" # for lcov
                  "kernel"
                ];
+      fedora_common = [ "fedora-release" "dlm-devel" "corosynclib-devel" ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" ];
       centos64 = centos63;
       centos65 = centos64;
-      fedora16 = [ "clusterlib-devel" "openaislib-devel" "cman" "systemd-devel" "libudev-devel" ];
-      fedora17 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
-                   "dlm" "systemd-devel" "perl-Digest-MD5" "libudev-devel" ];
+      centos70 = fedora20;
+
+      fedora17 = fedora18 ++ [ "libudev-devel" ];
 
-      fedora18 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
+      fedora18 = [ "fedora-release" "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
       fedora18u = fedora18;
 
-      fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng"
-                   "valgrind-devel" ];
+      fedora19 = [ "fedora-release" "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
+                   "procps-ng" "valgrind-devel" ];
       fedora19u = fedora19;
 
       fedora20 = fedora19;
       fedora20u = fedora20;
 
-      centos70 = fedora20;
-
       rawhide = fedora20;
     } // over.install_rpms;
 


