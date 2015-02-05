From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:41 +0000 (UTC)
Subject: master - NIX: Do not fail aggregation when a sub-job fails to produce output.
Message-ID: <20150205134241.570C6601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1d273a0b09cf2de58921dbf72459fe16b3b6c6a
Commit:        f1d273a0b09cf2de58921dbf72459fe16b3b6c6a
Parent:        93d8455faac76f5dcbf40f45d28aaf506856eb85
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 10 18:18:45 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Do not fail aggregation when a sub-job fails to produce output.

---
 nix/default.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 6cadd32..96ad775 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -19,7 +19,7 @@ let
        mkdir -p $out/test-results
        for i in ${lib.concatStringsSep " " buildInputs}; do
          cat $i/test-results/list >> $out/test-results/list
-         cp $i/test-results'/'*.txt $out/test-results/
+         cp $i/test-results'/'*.txt $out/test-results/ || true
        done
      '';
 


