From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:10 +0000 (UTC)
Subject: master - NIX: Make timeout and test envvars configurable via --arg.
Message-ID: <20150205134310.CA4DF60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4d5e22c91561a6722996e6b5c9735ae1397571d
Commit:        e4d5e22c91561a6722996e6b5c9735ae1397571d
Parent:        c2b7642d4d8df4a9d6798f339415466c9b69a805
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 17:06:19 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

NIX: Make timeout and test envvars configurable via --arg.

---
 nix/default.nix |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 5999bd2..fe1c377 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -4,7 +4,7 @@
   fc20_32_updates ? "", fc20_64_updates ? "",
   fc19_32_updates ? "", fc19_64_updates ? "",
   fc18_32_updates ? "", fc18_64_updates ? "",
-  T ? "" }:
+  T ? "", ENV ? "", timeout ? 60 }:
 
 let
   pkgs = import nixpkgs {};
@@ -58,8 +58,9 @@ let
            watch="--watch /xchg/udevd.log"
          fi
 
+         export ${ENV}
          lvm2-testsuite --batch --outdir /xchg/results --continue \
-             --fatal-timeouts --heartbeat /xchg/heartbeat \
+             --timeout ${toString timeout} --fatal-timeouts --heartbeat /xchg/heartbeat \
              --flavours ${flavour} $watch --kmsg ${if lib.eqStrings T "" then "" else "--only ${T}"}
 
          # TODO: coverage reports


