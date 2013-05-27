From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 03:58:13 +0000 (UTC)
Subject: dev-mornfall-nix - NIX: Fix a couple typos in build product handling.
Message-ID: <20130527035813.A869F61287@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a0869d850f81318aa18e4f17b6c2d7432b50310
Commit:        9a0869d850f81318aa18e4f17b6c2d7432b50310
Parent:        96d9004b32b96890b5255b13b3a885b5fdad5ac7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 05:57:01 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 05:57:01 2013 +0200

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


