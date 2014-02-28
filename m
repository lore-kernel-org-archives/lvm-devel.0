From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:59 +0000 (UTC)
Subject: master - NIX: Run system-wide tests separately, with RPMs installed.
Message-ID: <20140228102559.CDC6460F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c8db4e33ff9f2baab14d6cf6bdd09cd411f3c3b
Commit:        9c8db4e33ff9f2baab14d6cf6bdd09cd411f3c3b
Parent:        d567d0d307f0e4200dc4a5138ce4079cc1560092
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 21:14:30 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Run system-wide tests separately, with RPMs installed.

---
 release.nix |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/release.nix b/release.nix
index 395b413..8fa4168 100644
--- a/release.nix
+++ b/release.nix
@@ -19,14 +19,23 @@ let
       rpm -Uv ${pkgs.fetchurl {
        url="ftp://ftp.isu.edu.tw/pub/Linux/Fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
+      dmesg -n 1 # avoid spilling dmesg into the main log, we capture it in harness
      '';
      postBuild = ''
-      cp -R /tmp/test-results $out/test-results && \
-      echo "report tests $out/test-results" >> $out/nix-support/hydra-build-products || \
-      true
-      cp -R /tmp/lcov $out/coverage && \
-      echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
-      true # not really fatal, although kinda disappointing
+      cd `cat /tmp/build-location`
+      mv test/results/list test/results/list-rpm
+      rpm -Uvh /tmp/rpmout/RPMS/*/*.rpm # */
+      (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) &
+      make check_system QUIET=1 T=${T} || touch $out/nix-support/failed
+      mv test/results/list test/results/list-system
+      cat test/results/list-* > test/results/list
+      cp -R test/results $out/test-results && \
+          echo "report tests $out/test-results" >> $out/nix-support/hydra-build-products || \
+          true
+      make lcov || true
+      cp -R lcov_reports $out/coverage && \
+          echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
+          true # not really fatal, although kinda disappointing
      '';
    };
 
@@ -169,11 +178,9 @@ let
          echo "%define check_commands \\";
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
-         echo "dmesg --console-level debug || dmesg 8 || true\\";
-         echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
-         echo "make check T=${T} || touch \$out/nix-support/failed \\"
-	 echo "cp -R test/results /tmp/test-results \\"
-         echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
+         echo "make check QUIET=1 T=${T} || touch \$out/nix-support/failed \\"
+	 echo "pwd > /tmp/build-location \\"
+	 echo "touch rpm-no-clean") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
             -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \
             -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 0.HYDRA," \


