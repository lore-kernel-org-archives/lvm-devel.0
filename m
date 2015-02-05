From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:23 +0000 (UTC)
Subject: master - NIX: Add valgrind-devel to the build environment.
Message-ID: <20150205134323.7B4AE60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3af008d4051d54d9138933d99ca234ede8ea6b05
Commit:        3af008d4051d54d9138933d99ca234ede8ea6b05
Parent:        2a8dc7fb538595ffecee53298a38a284f8df89c0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:18:46 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:04 2015 +0100

NIX: Add valgrind-devel to the build environment.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 8fc2152..603b3dc 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -285,7 +285,7 @@ let
   extra_rpms = rec {
       common = [ "libselinux-devel" "libsepol-devel" "ncurses-devel" "readline-devel"
                  "corosynclib-devel"
-                 "valgrind" "strace" "gdb"
+                 "valgrind" "valgrind-devel" "gdb" "strace"
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov


