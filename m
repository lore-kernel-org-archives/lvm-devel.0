From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:49 +0000 (UTC)
Subject: master - NIX: Mark builds with failed tests as such.
Message-ID: <20150205134249.BBD0E601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6884f8a87ee442b88d7c4b5dfb7af4a10c26670
Commit:        b6884f8a87ee442b88d7c4b5dfb7af4a10c26670
Parent:        8b80e949ea320d202f5ccade2e79a5a3c5937368
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 11:12:12 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Mark builds with failed tests as such.

---
 nix/default.nix |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index d023f6e..445b0a7 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -21,6 +21,8 @@ let
          cat $i/test-results/list >> $out/test-results/list
          cp $i/test-results'/'*.txt $out/test-results/ || true
        done
+       mkdir -p $out/nix-support
+       grep '\<failed\>' $out/test-results/list && touch $out/nix-support/failed
      '';
 
      buildInputs = map (x: runTest (args // { flavour = x; }))


