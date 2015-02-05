From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:53 +0000 (UTC)
Subject: master - NIX: Move corosynclib-devel & valgrind-devel out of common.
Message-ID: <20150205134353.2656160B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cd6cce5a41cd5583470c45bad2dad4b08f04ad2
Commit:        5cd6cce5a41cd5583470c45bad2dad4b08f04ad2
Parent:        57c39ecbcd6b97643f99427dfe426cc20c1acd66
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 14 17:29:13 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:37 2015 +0100

NIX: Move corosynclib-devel & valgrind-devel out of common.

---
 nix/default.nix |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index cd92b91..b72379e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -293,13 +293,12 @@ let
 
   install_rpms = rec {
       common = [ "libselinux-devel" "libsepol-devel" "ncurses-devel" "readline-devel"
-                 "corosynclib-devel"
-                 "valgrind" "valgrind-devel" "gdb" "strace"
+                 "valgrind" "gdb" "strace"
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov
                ];
-      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" ];
+      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" ];
       centos64 = centos63;
       centos65 = centos64;
       fedora16 = [ "clusterlib-devel" "openaislib-devel" "cman" "systemd-devel" "libudev-devel" ];
@@ -310,7 +309,7 @@ let
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
       fedora18u = fedora18;
 
-      fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" ];
+      fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" "valgrind-devel" ];
       fedora19u = fedora19;
 
       fedora20 = fedora19;


