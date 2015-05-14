From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 09:42:48 +0000 (UTC)
Subject: master - nix: add more packages
Message-ID: <20150514094248.19F3560139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f375d03dd2fba5b32eb8547fdb0f95f30e0bc8c
Commit:        4f375d03dd2fba5b32eb8547fdb0f95f30e0bc8c
Parent:        f3a19fbe134086d46b29f9299074cc2a6c639fd7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 11:42:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 11:42:33 2015 +0200

nix: add more packages

---
 nix/default.nix |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 3879fc1..8a5521a 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -354,6 +354,8 @@ let
                  "valgrind" "valgrind-devel" "gdb" "strace"
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
+                 "e2fsprogs-libs" "e2fsprogs-devel"
+                 "util-linux"
                  "perl-GD" # for lcov
                  "mdadm" # for tests with lvm2 and mdadm
                  "device-mapper-persistent-data" # thin and cache
@@ -370,7 +372,7 @@ let
 
       fedora17 = fedora18 ++ [ "libudev-devel" ];
 
-      fedora18 = [ "dlm-devel" "corosynclib-devel" "nc"
+      fedora18 = [ "dlm-devel" "corosynclib-devel" "nc" "libblkid" "libblkid-devel"
                    "dlm" "systemd-devel" "perl-Digest-MD5" "kernel-modules-extra" ];
       fedora18u = fedora18;
 


