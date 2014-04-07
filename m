From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  7 Apr 2014 18:39:11 +0000 (UTC)
Subject: master - NIX: Avoid test-installing lvm2-sysvinit (fails on recent Fedoras).
Message-ID: <20140407183911.552A460564@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05a421960f5770e1047cc5212d2a11deef730152
Commit:        05a421960f5770e1047cc5212d2a11deef730152
Parent:        0996b5ccf47c516b9504bc524b599ecb54800b6b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Apr 7 20:37:30 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Apr 7 20:38:43 2014 +0200

NIX: Avoid test-installing lvm2-sysvinit (fails on recent Fedoras).

---
 nix/default.nix |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 140ae7f..81e9d30 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -14,6 +14,7 @@ let
      src = jobs.tarball;
      diskImage = diskFun { extraPackages = extras; };
      memSize = 768;
+
      # fc16 lcov is broken and el6 has none... be creative
      prepareImagePhase = ''
       rpm -Uv ${pkgs.fetchurl {
@@ -21,10 +22,12 @@ let
        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
       dmesg -n 1 # avoid spilling dmesg into the main log, we capture it in harness
      '';
+
      postBuild = ''
+      mkdir -p $out/nix-support
       cd `cat /tmp/build-location`
       mv test/results/list test/results/list-rpm
-      rpm -Uvh /tmp/rpmout/RPMS/*/*.rpm # */
+      ls /tmp/rpmout/RPMS/*/*.rpm | grep -v sysvinit | xargs rpm -Uvh # */
       (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || find / -xdev -name \*udevd) &
       make check_system QUIET=1 T=${T} || touch $out/nix-support/failed
       mv test/results/list test/results/list-system
@@ -37,6 +40,16 @@ let
           echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
           true # not really fatal, although kinda disappointing
      '';
+
+     postInstall = ''
+      for i in $out/rpms/*/*.rpm; do
+        if echo $i | grep -vq "\.src\.rpm$"; then
+          echo "file rpm $i" >> $out/nix-support/hydra-build-products
+        else
+          echo "file srpm $i" >> $out/nix-support/hydra-build-products
+        fi
+      done
+     '';
    };
 
   rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix"
@@ -137,7 +150,7 @@ let
     imgs = pkgs.vmTools.diskImageFuns //
             mapAttrs (n: a: b: pkgs.vmTools.makeImageFromRPMDist (a // b)) extra_distros;
     rpmdistros = pkgs.vmTools.rpmDistros // extra_distros;
-    rpmbuild = release.rpmBuild;
+    rpmbuild = pkgs.vmTools.buildRPM;
   };
 
   extra_rpms = rec {


