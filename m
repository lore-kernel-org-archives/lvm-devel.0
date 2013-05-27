From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 02:28:26 +0000 (UTC)
Subject: dev-mornfall-nix - NIX: Copy collected test results into the output.
Message-ID: <20130527022826.3E9EE60F44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96d9004b32b96890b5255b13b3a885b5fdad5ac7
Commit:        96d9004b32b96890b5255b13b3a885b5fdad5ac7
Parent:        71eb26fcee82565ad6d18d6b31baa0a2ccd6029e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 04:27:26 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 04:27:26 2013 +0200

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


