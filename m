From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:11 +0000 (UTC)
Subject: master - NIX: Add an fc18 build that includes fedora updates.
Message-ID: <20140228102511.9472B60CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28143505f83ab0e62de326118c64a834885618fc
Commit:        28143505f83ab0e62de326118c64a834885618fc
Parent:        c5fbccab21fda0b829e55be7d5045f1dbae1e811
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 23:37:17 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Add an fc18 build that includes fedora updates.

---
 release.nix |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 503c1f0..6fd0735 100644
--- a/release.nix
+++ b/release.nix
@@ -1,4 +1,8 @@
-{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false, rawhide32 ? "" , rawhide64 ? "" , fc19_32 ? "" , fc19_64 ? "", lvm2Nix ? lvm2Src, T ? "" }:
+{ nixpkgs ? <nixpkgs>, lvm2Src, release ? false,
+  rawhide32 ? "" , rawhide64 ? "" ,
+  fc19_32 ? "" , fc19_64 ? "",
+  fc18_32_updates ? "", fc18_64_updates ? "",
+  lvm2Nix ? lvm2Src, T ? "" }:
 
 let
   pkgs = import nixpkgs {};
@@ -32,6 +36,7 @@ let
   fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"
                        then "ftp://ftp.fi.muni.cz/pub/linux/fedora/linux/development/${ver}/${arch}/os/"
                        else "mirror://fedora/linux/releases/${ver}/Everything/${arch}/os/";
+  fedora_update_url = ver: arch: "mirror://fedora/linux/updates/${ver}/${arch}";
   extra_distros = with pkgs.lib; let
       centos = { version, sha, arch }: {
         name = "centos-${version}-${arch}";
@@ -61,11 +66,23 @@ let
         sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
         echo '{fedora}: fedora { version = "${version}"; sha = "'$sha'"; arch = "${arch}"; }' > $out
       '') { inherit fedora; };
+      update = version: arch: repodata: orig: orig // (import (pkgs.runCommand "updates-fedora.nix" {} ''
+          sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
+          (echo 'fetchurl: { packagesLists = [ "${orig.packagesList}" ('
+           echo "fetchurl { "
+           echo "  url = \"${fedora_update_url version arch}/repodata/$sha-primary.xml.gz\";"
+           echo "  sha256 = \"$sha\";"
+           echo '} ) ]; urlPrefixes = [ "${orig.urlPrefix}" "${fedora_update_url version arch}" ]; }'
+          ) > $out
+          echo built $out 1>&2
+        '')) pkgs.fetchurl;
     in {
       rawhidex86_64 = rawhide "rawhide" "x86_64" rawhide64;
       rawhidei386 = rawhide "rawhide" "i386" rawhide32;
       fedora19x86_64 = rawhide "19" "x86_64" fc19_64;
       fedora19i386 = rawhide "19" "i386" fc19_32;
+      fedora18ux86_64 = update "18" "x86_64" fc18_64_updates pkgs.vmTools.rpmDistros.fedora18x86_64;
+      fedora18ui386 = update "18" "i386" fc18_32_updates pkgs.vmTools.rpmDistros.fedora18i386;
 
       centos63x86_64 = centos {
         version="6.3"; arch="x86_64";
@@ -114,6 +131,7 @@ let
                    "dlm" "systemd-devel" "perl-Digest-MD5" "libudev-devel" ];
       fedora18 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
+      fedora18u = fedora18;
       fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" ];
       rawhide = fedora19;
     };
@@ -176,6 +194,9 @@ let
     fc16_x86_64 = mkRPM { arch = "x86_64"; image = "fedora16"; };
     fc16_i386   = mkRPM { arch = "i386"  ; image = "fedora16"; };
 
+    fc18u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora18u"; };
+    fc18u_i386   = mkRPM { arch = "x86_64"; image = "fedora18u"; };
+
     centos63_i386 = mkRPM { arch = "i386"  ; image = "centos63"; };
     centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };
     centos64_i386 = mkRPM { arch = "i386"  ; image = "centos64"; };


