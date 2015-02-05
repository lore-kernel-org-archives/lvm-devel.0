From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:52 +0000 (UTC)
Subject: master - NIX: Refactor around the new test runner.
Message-ID: <20150205134152.AB2996052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b5ae314049cebbd1b4f6ad35fd11d957a50db8e
Commit:        4b5ae314049cebbd1b4f6ad35fd11d957a50db8e
Parent:        d5537e7d6b28d2a7f2214529797aade0ed29efab
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:25:18 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Refactor around the new test runner.

- The RPM build and the tests are now executed in separate VMs.
- Run the testsuite by using the new lvm2-testsuite RPM.
- The VM running the tests is restarted from the outside if it hangs, and the
  runner keeps a journal to avoid running a bad test ad infinitum.
- TODO: lcov reports and more intelligent VM rebooting (track the journal)
---
 nix/default.nix |  229 ++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 149 insertions(+), 80 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index abd3d01..2ea248e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -2,47 +2,106 @@
   rawhide32 ? "" , rawhide64 ? "" ,
   fc19_32_updates ? "", fc19_64_updates ? "",
   fc18_32_updates ? "", fc18_64_updates ? "",
-  lvm2Nix ? lvm2Src, T ? "" }:
+  T ? "" }:
 
 let
   pkgs = import nixpkgs {};
-  mkVM = { VM, extras ? [], diskFun, kernel }:
-   VM rec {
-     inherit kernel;
-     name = "lvm2";
-     fullName = "LVM2";
-     src = jobs.tarball;
+  lib = pkgs.lib;
+  mkTest = { build, diskFun, extras ? [], kernel, vmtools, ... }: pkgs.stdenv.mkDerivation rec {
      diskImage = diskFun { extraPackages = extras; };
-     memSize = 2047;
-
-     # fc16 lcov is broken and el6 has none... be creative
-     prepareImagePhase = ''
-      rpm -Uv ${pkgs.fetchurl {
-       url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
-       sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
-      dmesg -n 1 # avoid spilling dmesg into the main log, we capture it in harness
+     name = "lvm2-test-${diskImage.name}";
+
+     # this is the builder that runs in the guest
+     origBuilder = pkgs.writeScript "vm-test-guest" ''
+         #!/bin/bash
+         export PATH=/usr/bin:/bin:/usr/sbin:/sbin
+
+	 # we always run in a fresh image, so need to install everything again
+         ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uvh # */
+         rpm -Uv ${pkgs.fetchurl {
+            url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
+            sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
+
+         mkdir -p /tmp/xchg/results-{udev,ndev}
+
+         dmsetup targets
+
+         export LVM_TEST_BACKING_DEVICE=/dev/vdb
+         if ! test -e /tmp/xchg/results-ndev/list; then
+             lvm2-testsuite --outdir /tmp/xchg/results-ndev --continue \
+                 --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
+         fi
+
+         if ! test -e /tmp/xchg/results-udev/list; then
+             (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
+                 find / -xdev -name \*udevd) &
+             lvm2-testsuite --outdir /tmp/xchg/results-udev --continue \
+                 --flavours udev-vanilla,udev-cluster,udev-lvmetad
+         fi
+
+         # if we made it this far, all test results are in
+
+         # TODO: coverage reports
+         # make lcov || true
+         # cp -R lcov_reports $out/coverage && \
+         #     echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
+         #     true # not really fatal, although kinda disappointing
      '';
 
-     postBuild = ''
-      mkdir -p $out/nix-support
-      cd `cat /tmp/build-location`
-      mv test/results/list test/results/list-rpm
-      ls /tmp/rpmout/RPMS/*/*.rpm | grep -v sysvinit | xargs rpm -Uvh # */
-      (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || find / -xdev -name \*udevd) &
-      make check_system QUIET=1 T=${T} || touch $out/nix-support/failed
-      mv test/results/list test/results/list-system
-      cat test/results/list-* > test/results/list
-      cp -R test/results $out/test-results && \
-          echo "report tests $out/test-results" >> $out/nix-support/hydra-build-products || \
-          true
-      make lcov || true
-      cp -R lcov_reports $out/coverage && \
-          echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
-          true # not really fatal, although kinda disappointing
+     buildInputs = [ pkgs.coreutils pkgs.bash pkgs.utillinux ];
+
+     # make a qcow copy of the main image
+     preVM = ''
+       diskImage=$(pwd)/disk-image.qcow2
+       origImage=${diskImage}
+       if test -d "$origImage"; then origImage="$origImage/disk-image.qcow2"; fi
+       ${vmtools.qemu}/bin/qemu-img create -b "$origImage" -f qcow2 $diskImage
+     '';
+
+     builder = pkgs.writeScript "vm-test" ''
+       #!${pkgs.bash}/bin/bash
+       . $stdenv/setup
+       set -x
+
+       export QEMU_OPTS="-drive file=/dev/shm/testdisk.img,if=virtio -m 256M"
+       export KERNEL_OPTS="log_buf_len=131072"
+       export mountDisk=1
+
+       mkdir -p $out/test-results $out/nix-support
+       touch $out/nix-support/failed
+
+       # give it 9x 20 minutes, i.e. about 3 hours
+       for i in seq 1 9; do
+           ${vmtools.qemu}/bin/qemu-img create -f qcow2 /dev/shm/testdisk.img 4G
+           setsid bash -e ${vmtools.vmRunCommand (vmtools.qemuCommandLinux kernel)} &
+           pid=$!
+           ( sleep 1200 ; kill -- -$pid ) &
+           if wait $pid; then
+               rm -f $out/nix-support/failed
+               break
+           fi
+           mv xchg/results-*'/'*.txt $out/test-results/
+           sleep 5
+       done
+
+       # use journals in case the lists weren't actually written yet
+       cat xchg/results-ndev/journal xchg/results-udev/journal > $out/test-results/list || true
      '';
+  };
+
+  mkBuild = { VM, extras ? [], diskFun, ... }:
+   VM rec {
+     name = "lvm2-build-${diskImage.name}";
+     fullName = "lvm2-build-${diskImage.name}";
+
+     src = jobs.tarball;
+     diskImage = diskFun { extraPackages = extras; };
+     memSize = 512;
+     checkPhase = ":";
 
      postInstall = ''
-      for i in $out/rpms/*/*.rpm; do
+      mkdir -p $out/nix-support
+      for i in $out/rpms/*/*.rpm; do # */
         if echo $i | grep -vq "\.src\.rpm$"; then
           echo "file rpm $i" >> $out/nix-support/hydra-build-products
         else
@@ -58,11 +117,11 @@ let
   centos_url = ver: arch: if ver == "6.5"
        then "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/"
        else "http://vault.centos.org/${ver}/os/${arch}/";
-  fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"
+  fedora_url = ver: arch: if lib.eqStrings ver "rawhide" || lib.eqStrings ver "19"
                        then "ftp://ftp.fi.muni.cz/pub/linux/fedora/linux/development/${ver}/${arch}/os/"
                        else "mirror://fedora/linux/releases/${ver}/Everything/${arch}/os/";
   fedora_update_url = ver: arch: "mirror://fedora/linux/updates/${ver}/${arch}";
-  extra_distros = with pkgs.lib; let
+  extra_distros = with lib; let
       centos = { version, sha, arch }: {
         name = "centos-${version}-${arch}";
         fullName = "CentOS ${version} (${arch})";
@@ -141,7 +200,7 @@ let
       };
     };
 
-  vm = pkgs: xmods: with pkgs.lib; rec {
+  vm = pkgs: xmods: with lib; rec {
     tools = import "${nixpkgs}/pkgs/build-support/vm/default.nix" {
       inherit pkgs; rootModules = rootmods ++ xmods ++
         [ "loop" "dm_mod" "dm_snapshot" "dm_mirror" "dm_zero" "dm_raid" "dm_thin_pool" ]; };
@@ -174,17 +233,48 @@ let
       rawhide = fedora19;
     };
 
-  mkRPM = { arch, image }: with pkgs.lib;
+  wrapper = fun: { arch, image, build ? {} }: with lib;
     let use = vm (if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs)
                  (if image == "centos64" || image == "centos65" then [] else [ "9p" "9pnet_virtio" ]);
-     in mkVM {
+     in fun {
+           inherit build;
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;
            extras = extra_rpms.common ++ builtins.getAttr image extra_rpms;
+           vmtools = use.tools;
            kernel = use.tools.makeKernelFromRPMDist (builtins.getAttr "${image}${arch}" use.rpmdistros);
         };
 
-  jobs = rec {
+  configs = {
+    fc19_x86_64 = { arch = "x86_64"; image = "fedora19"; };
+    fc19_i386   = { arch = "i386"  ; image = "fedora19"; };
+    fc18_x86_64 = { arch = "x86_64"; image = "fedora18"; };
+    fc18_i386   = { arch = "i386"  ; image = "fedora18"; };
+    fc17_x86_64 = { arch = "x86_64"; image = "fedora17"; };
+    fc17_i386   = { arch = "i386"  ; image = "fedora17"; };
+    fc16_x86_64 = { arch = "x86_64"; image = "fedora16"; };
+    fc16_i386   = { arch = "i386"  ; image = "fedora16"; };
+
+    fc18u_x86_64 = { arch = "x86_64"; image = "fedora18u"; };
+    fc18u_i386   = { arch = "i386"; image = "fedora18u"; };
+    fc19u_x86_64 = { arch = "x86_64"; image = "fedora19u"; };
+    fc19u_i386   = { arch = "i386"; image = "fedora19u"; };
+
+    #centos63_i386   = { arch = "i386"  ; image = "centos63"; };
+    #centos63_x86_64 = { arch = "x86_64" ; image = "centos63"; };
+    centos64_i386   = { arch = "i386"  ; image = "centos64"; };
+    centos64_x86_64 = { arch = "x86_64" ; image = "centos64"; };
+    centos65_i386   = { arch = "i386"  ; image = "centos65"; };
+    centos65_x86_64 = { arch = "x86_64" ; image = "centos65"; };
+
+    rawhide_i386   = { arch = "i386"  ; image = "rawhide"; };
+    rawhide_x86_64 = { arch = "x86_64" ; image = "rawhide"; };
+  };
+
+  rpms = lib.mapAttrs (n: v: wrapper mkBuild v) configs;
+  tests = lib.mapAttrs (n: v: wrapper mkTest (v // { build = builtins.getAttr n rpms; })) configs;
+
+  jobs = tests // {
     tarball = pkgs.releaseTools.sourceTarball rec {
       name = "lvm2-tarball";
       versionSuffix = if lvm2Src ? revCount
@@ -193,31 +283,34 @@ let
       src = lvm2Src;
       autoconfPhase = ":";
       distPhase = ''
-        set -x
         make distclean
+
         version=`cat VERSION | cut "-d(" -f1`${versionSuffix}
         version_dm=`cat VERSION_DM | cut "-d-" -f1`${versionSuffix}
-        sed -e s,-git,${versionSuffix}, -i VERSION VERSION_DM
-        rm -rf spec; cp -R ${lvm2Nix}/spec/* .
+
         chmod u+w *
-        (echo "%define enable_profiling 1";
-         echo "%define check_commands \\";
-         echo "make lcov-reset \\";
-         echo "dmsetup targets\\";
-         echo "mkdir -p \$out/nix-support \\";
-         echo "make check QUIET=1 T=${T} || touch \$out/nix-support/failed \\"
-	 echo "pwd > /tmp/build-location \\"
-	 echo "touch rpm-no-clean") >> source.inc
+
+        # set up versions
+        sed -e s,-git,${versionSuffix}, -i VERSION VERSION_DM
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
             -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \
             -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 0.HYDRA," \
-            -e "s:%with clvmd corosync:%with clvmd corosync,singlenode:" \
-            -i source.inc
-        sed -e '/^%changelog/,$d' \
-            -i lvm2.spec
-        echo "%changelog" >> lvm2.spec;
-        echo "* `date +"%a %b %d %Y"` Petr Rockai <prockai@redhat.com> - $version" >> lvm2.spec;
-        echo "- AUTOMATED BUILD BY Hydra" >> lvm2.spec
+            -i spec/source.inc
+
+        # tweak RPM configuration
+        echo   "%define enable_profiling 1" >> spec/source.inc
+        echo   "%define enable_testsuite 1" >> spec/source.inc
+        sed -e "s:%with clvmd corosync:%with clvmd corosync,singlenode:" -i spec/source.inc
+
+        # synthesize a changelog
+        sed -e '/^%changelog/,$d' -i spec/lvm2.spec
+        (echo "%changelog";
+         echo "* `date +"%a %b %d %Y"` Petr Rockai <prockai@redhat.com> - $version";
+         echo "- AUTOMATED BUILD BY Hydra") >> spec/lvm2.spec
+
+        mv spec/* . && rmdir spec # */ # RPM needs the spec file in the source root
+
+        # make a tarball
         mkdir ../LVM2.$version
         mv * ../LVM2.$version
         ensureDir $out/tarballs
@@ -225,29 +318,5 @@ let
         tar cvzf $out/tarballs/LVM2.$version.tgz LVM2.$version
       '';
     };
-
-    fc19_x86_64 = mkRPM { arch = "x86_64"; image = "fedora19"; };
-    fc19_i386   = mkRPM { arch = "i386"  ; image = "fedora19"; };
-    fc18_x86_64 = mkRPM { arch = "x86_64"; image = "fedora18"; };
-    fc18_i386   = mkRPM { arch = "i386"  ; image = "fedora18"; };
-    fc17_x86_64 = mkRPM { arch = "x86_64"; image = "fedora17"; };
-    fc17_i386   = mkRPM { arch = "i386"  ; image = "fedora17"; };
-    fc16_x86_64 = mkRPM { arch = "x86_64"; image = "fedora16"; };
-    fc16_i386   = mkRPM { arch = "i386"  ; image = "fedora16"; };
-
-    fc18u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora18u"; };
-    fc18u_i386   = mkRPM { arch = "i386"; image = "fedora18u"; };
-    fc19u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora19u"; };
-    fc19u_i386   = mkRPM { arch = "i386"; image = "fedora19u"; };
-
-    #centos63_i386 = mkRPM { arch = "i386"  ; image = "centos63"; };
-    #centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };
-    centos64_i386 = mkRPM { arch = "i386"  ; image = "centos64"; };
-    centos64_x86_64 = mkRPM { arch = "x86_64" ; image = "centos64"; };
-    centos65_i386 = mkRPM { arch = "i386"  ; image = "centos65"; };
-    centos65_x86_64 = mkRPM { arch = "x86_64" ; image = "centos65"; };
-
-    rawhide_i386 = mkRPM { arch = "i386"  ; image = "rawhide"; };
-    rawhide_x86_64 = mkRPM { arch = "x86_64" ; image = "rawhide"; };
   };
 in jobs


