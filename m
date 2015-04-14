From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Apr 2015 20:22:13 +0000 (UTC)
Subject: master - NIX: Disable profiling in all but one configuration.
Message-ID: <20150414202213.A84F2602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=026c38ac1e2ef8a65938919233a2a8a1f55fcd7c
Commit:        026c38ac1e2ef8a65938919233a2a8a1f55fcd7c
Parent:        24352aff2b30ad23aebd444c752d8b6dd02c9f03
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Apr 7 11:54:25 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 14 20:18:27 2015 +0200

NIX: Disable profiling in all but one configuration.

---
 nix/default.nix |   99 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 52 insertions(+), 47 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index da1fa08..b8e0061 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -161,12 +161,56 @@ let
      '';
   };
 
-  mkBuild = { VM, extras ? [], diskFun, ... }:
+  mkTarball = profiling: pkgs.releaseTools.sourceTarball rec {
+    name = "lvm2-tarball";
+    versionSuffix = if lvm2Src ? revCount
+                       then ".pre${toString lvm2Src.revCount}"
+                       else "";
+    src = lvm2Src;
+    autoconfPhase = ":";
+    distPhase = ''
+      make distclean
+
+      version=`cat VERSION | cut "-d(" -f1`${versionSuffix}
+      version_dm=`cat VERSION_DM | cut "-d-" -f1`${versionSuffix}
+
+      chmod u+w *
+
+      # set up versions
+      sed -e s,-git,${versionSuffix}, -i VERSION VERSION_DM
+      sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
+          -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \
+          -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 0.HYDRA," \
+          -i spec/source.inc
+
+      # tweak RPM configuration
+      echo   "%define enable_profiling ${profiling}" >> spec/source.inc
+      echo   "%define enable_testsuite 1" >> spec/source.inc
+      sed -e "s:%with clvmd corosync:%with clvmd corosync,singlenode:" -i spec/source.inc
+
+      # synthesize a changelog
+      sed -e '/^%changelog/,$d' -i spec/lvm2.spec
+      (echo "%changelog";
+       echo "* `date +"%a %b %d %Y"` Petr Rockai <prockai@redhat.com> - $version";
+       echo "- AUTOMATED BUILD BY Hydra") >> spec/lvm2.spec
+
+      mv spec/* . && rmdir spec # */ # RPM needs the spec file in the source root
+
+      # make a tarball
+      mkdir ../LVM2.$version
+      mv * ../LVM2.$version
+      ensureDir $out/tarballs
+      cd ..
+      tar cvzf $out/tarballs/LVM2.$version.tgz LVM2.$version
+    '';
+  };
+
+  mkBuild = { src, VM, extras ? [], diskFun, ... }:
    VM rec {
      name = "lvm2-build-${diskImage.name}";
      fullName = "lvm2-build-${diskImage.name}";
 
-     src = jobs.tarball;
+     inherit src;
      diskImage = diskFun { extraPackages = extras; };
      memSize = 512;
      checkPhase = ":";
@@ -335,13 +379,13 @@ let
       rawhide = fedora20;
     } // over.install_rpms;
 
-  wrapper = fun: { arch, image, build ? {}, istest ? false }: with lib;
+  wrapper = fun: { arch, image, build ? {}, istest ? false, src ? jobs.tarball }: with lib;
     let use = vm { pkgs = if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs;
                    xmods = if istest && (image == "centos64" || image == "centos65")
                               then [] else [ "9p" "9pnet_virtio" ];
                    dmmods = istest; };
      in fun {
-           inherit build istest;
+           inherit build istest src;
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;
            extras = install_rpms.common ++ builtins.getAttr image install_rpms;
@@ -350,6 +394,8 @@ let
         };
 
   configs = {
+    fc20p_x86_64 = { arch = "x86_64"; image = "fedora20"; src = jobs.tarball_prof; };
+    fc20p_i386   = { arch = "i386"  ; image = "fedora20"; src = jobs.tarball_prof; };
     fc20_x86_64 = { arch = "x86_64"; image = "fedora20"; };
     fc20_i386   = { arch = "i386"  ; image = "fedora20"; };
     fc19_x86_64 = { arch = "x86_64"; image = "fedora19"; };
@@ -384,48 +430,7 @@ let
            in lib.mapAttrs make configs;
 
   jobs = tests // {
-    tarball = pkgs.releaseTools.sourceTarball rec {
-      name = "lvm2-tarball";
-      versionSuffix = if lvm2Src ? revCount
-                         then ".pre${toString lvm2Src.revCount}"
-                         else "";
-      src = lvm2Src;
-      autoconfPhase = ":";
-      distPhase = ''
-        make distclean
-
-        version=`cat VERSION | cut "-d(" -f1`${versionSuffix}
-        version_dm=`cat VERSION_DM | cut "-d-" -f1`${versionSuffix}
-
-        chmod u+w *
-
-        # set up versions
-        sed -e s,-git,${versionSuffix}, -i VERSION VERSION_DM
-        sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
-            -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \
-            -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 0.HYDRA," \
-            -i spec/source.inc
-
-        # tweak RPM configuration
-        echo   "%define enable_profiling 1" >> spec/source.inc
-        echo   "%define enable_testsuite 1" >> spec/source.inc
-        sed -e "s:%with clvmd corosync:%with clvmd corosync,singlenode:" -i spec/source.inc
-
-        # synthesize a changelog
-        sed -e '/^%changelog/,$d' -i spec/lvm2.spec
-        (echo "%changelog";
-         echo "* `date +"%a %b %d %Y"` Petr Rockai <prockai@redhat.com> - $version";
-         echo "- AUTOMATED BUILD BY Hydra") >> spec/lvm2.spec
-
-        mv spec/* . && rmdir spec # */ # RPM needs the spec file in the source root
-
-        # make a tarball
-        mkdir ../LVM2.$version
-        mv * ../LVM2.$version
-        ensureDir $out/tarballs
-        cd ..
-        tar cvzf $out/tarballs/LVM2.$version.tgz LVM2.$version
-      '';
-    };
+     tarball_prof = mkTarball "1";
+     tarball = mkTarball "0";
   };
 in jobs


