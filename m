From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:05 +0000 (UTC)
Subject: master - NIX: Fix a couple typos in build product handling.
Message-ID: <20140228102505.5AF51609E0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39c8cd3d05edc07b9eaba8459703838ae6119ad7
Commit:        39c8cd3d05edc07b9eaba8459703838ae6119ad7
Parent:        4fdcb27b3e61fdbd487f9918e0017184b80f27e5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 05:57:01 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Fix a couple typos in build product handling.

---
 release.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/release.nix b/release.nix
index 24d0a19..985a568 100644
--- a/release.nix
+++ b/release.nix
@@ -18,7 +18,7 @@ let
      '';
      postBuild = ''
       cp -R /tmp/test-results $out/test-results && \
-      echo "report tests $out/test-results " >> $out/nix-support/hydra-build-products || \
+      echo "report tests $out/test-results" >> $out/nix-support/hydra-build-products || \
       true
       cp -R /tmp/lcov $out/coverage && \
       echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
@@ -148,7 +148,7 @@ let
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
          echo "make check || touch \$out/nix-support/failed \\"
-	 echo "cp -R test/results /tmp/test-results"
+	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
             -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \


