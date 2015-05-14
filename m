From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 08:53:50 +0000 (UTC)
Subject: master - nix: socat is quite new package
Message-ID: <20150514085350.2FB1B601FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1406aba8da1a74cc038ae0a8e71e940341b4b7ba
Commit:        1406aba8da1a74cc038ae0a8e71e940341b4b7ba
Parent:        b7d80806b68a97cde6dfdf64ef7bc31e9c42a6b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 09:49:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 10:52:55 2015 +0200

nix: socat is quite new package

Install 'nc' on older systems.
Test suite handles both.
---
 nix/default.nix |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index b3acc0e..5c2e3d3 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -357,19 +357,19 @@ let
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
                  "device-mapper-persistent-data" # thin and cache
-                 "socat" # used by test suite lvmpolld
                  "kernel"
                ];
-      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "procps" ];
+      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "procps" "nc" ];
       centos64 = centos63 ++ [ "corosynclib-devel" ];
       centos65 = centos64;
       centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
+                   "socat" # used by test suite lvmpolld
                    "procps-ng" ];
 
       fedora17 = fedora18 ++ [ "libudev-devel" ];
 
-      fedora18 = [ "dlm-devel" "corosynclib-devel"
+      fedora18 = [ "dlm-devel" "corosynclib-devel" "nc"
                    "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
       fedora18u = fedora18;
 


