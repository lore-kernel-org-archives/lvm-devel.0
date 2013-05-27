From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 03:58:15 +0000 (UTC)
Subject: dev-mornfall-nix - NIX: Make it possible to only run a subset of tests (via T).
Message-ID: <20130527035815.BEB7761287@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da087da6844f543c7c8dd12d4ac1bc6920ce41a8
Commit:        da087da6844f543c7c8dd12d4ac1bc6920ce41a8
Parent:        9a0869d850f81318aa18e4f17b6c2d7432b50310
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 05:57:32 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 05:57:32 2013 +0200

NIX: Make it possible to only run a subset of tests (via T).

---
 release.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/release.nix b/release.nix
index 985a568..334a19f 100644
--- a/release.nix
+++ b/release.nix
@@ -1,4 +1,4 @@
-{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false, rawhide32 ? "" , rawhide64 ? "" , fc19_32 ? "" , fc19_64 ? "", lvm2Nix ? lvm2Src }:
+{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false, rawhide32 ? "" , rawhide64 ? "" , fc19_32 ? "" , fc19_64 ? "", lvm2Nix ? lvm2Src, T ? "" }:
 
 let
   pkgs = import nixpkgs {};
@@ -147,7 +147,7 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "make check || touch \$out/nix-support/failed \\"
+         echo "make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \


