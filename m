From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:12 +0000 (UTC)
Subject: master - NIX: Install valgrind, gdb and strace in the test environment.
Message-ID: <20150205134312.E7EDF60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41c2e07a8dee3d3e5212c7c1939ddbd4624d3bed
Commit:        41c2e07a8dee3d3e5212c7c1939ddbd4624d3bed
Parent:        e4d5e22c91561a6722996e6b5c9735ae1397571d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 17:06:46 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:50:23 2015 +0100

NIX: Install valgrind, gdb and strace in the test environment.

---
 nix/default.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index fe1c377..8fc2152 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -285,6 +285,7 @@ let
   extra_rpms = rec {
       common = [ "libselinux-devel" "libsepol-devel" "ncurses-devel" "readline-devel"
                  "corosynclib-devel"
+                 "valgrind" "strace" "gdb"
                  "redhat-rpm-config" # needed for rpmbuild of lvm
                  "which" "e2fsprogs" # needed for fsadm
                  "perl-GD" # for lcov


