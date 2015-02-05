From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:55 +0000 (UTC)
Subject: master - NIX: We need to install lcov for ./configure now as well.
Message-ID: <20150205134355.429ED60B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81b34dce6173cb8599aebb5e052d8df573d3aecb
Commit:        81b34dce6173cb8599aebb5e052d8df573d3aecb
Parent:        5cd6cce5a41cd5583470c45bad2dad4b08f04ad2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Feb 5 13:30:02 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:38 2015 +0100

NIX: We need to install lcov for ./configure now as well.

---
 nix/default.nix |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index b72379e..6bb94db 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -11,6 +11,11 @@ let
   pkgs = import nixpkgs {};
   lib = pkgs.lib;
   over = overrides { inherit pkgs; };
+  install_lcov = ''
+     rpm -Uv ${pkgs.fetchurl {
+        url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
+        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
+  '';
 
   mkTest = args: pkgs.stdenv.mkDerivation rec {
      name = "lvm2-test-${(args.diskFun {}).name}";
@@ -42,9 +47,7 @@ let
 
          # we always run in a fresh image, so need to install everything again
          ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uv --oldpackage # */
-         rpm -Uv ${pkgs.fetchurl {
-            url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
-            sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
+         ${install_lcov}
 
          mkdir -p /xchg/results
          touch /xchg/booted
@@ -168,6 +171,8 @@ let
      memSize = 512;
      checkPhase = ":";
 
+     preConfigure = install_lcov;
+
      postInstall = ''
       mkdir -p $out/nix-support
       for i in $out/rpms/*/*.rpm; do # */


