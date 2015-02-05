From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:57 +0000 (UTC)
Subject: master - NIX: Adjust install_rpms (kernel rpm is now required).
Message-ID: <20150205134357.5880160B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9a017d94cb5ad432c51df861242f42cc4f01ba3
Commit:        b9a017d94cb5ad432c51df861242f42cc4f01ba3
Parent:        81b34dce6173cb8599aebb5e052d8df573d3aecb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Feb 5 13:30:18 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:39 2015 +0100

NIX: Adjust install_rpms (kernel rpm is now required).

---
 nix/default.nix |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 6bb94db..f9f025f 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -302,6 +302,7 @@ let
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov
+                 "kernel"
                ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" ];
       centos64 = centos63;
@@ -314,7 +315,8 @@ let
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
       fedora18u = fedora18;
 
-      fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" "valgrind-devel" ];
+      fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng"
+                   "valgrind-devel" ];
       fedora19u = fedora19;
 
       fedora20 = fedora19;


