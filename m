From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:03 +0000 (UTC)
Subject: master - NIX: Copy collected test results into the output.
Message-ID: <20140228102503.48CF7609E0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fdcb27b3e61fdbd487f9918e0017184b80f27e5
Commit:        4fdcb27b3e61fdbd487f9918e0017184b80f27e5
Parent:        f6350b4568ee50d3c90aa883ca0cd9eee1410448
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 04:27:26 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:49 2014 +0100

NIX: Copy collected test results into the output.

---
 release.nix |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/release.nix b/release.nix
index 981609f..24d0a19 100644
--- a/release.nix
+++ b/release.nix
@@ -17,6 +17,9 @@ let
        sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
      '';
      postBuild = ''
+      cp -R /tmp/test-results $out/test-results && \
+      echo "report tests $out/test-results " >> $out/nix-support/hydra-build-products || \
+      true
       cp -R /tmp/lcov $out/coverage && \
       echo "report coverage $out/coverage" >> $out/nix-support/hydra-build-products || \
       true # not really fatal, although kinda disappointing
@@ -145,6 +148,7 @@ let
          echo "make lcov-reset \\";
          echo "dmsetup targets\\";
          echo "make check || touch \$out/nix-support/failed \\"
+	 echo "cp -R test/results /tmp/test-results"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \
             -e "s,^\(Version:[^0-9%]*\)[0-9.]*$,\1 $version," \


