From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:26 +0000 (UTC)
Subject: master - NIX: Update the release.nix path in build.sh.
Message-ID: <20140228102626.D7A4F60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea5ec4ad51e3270b6b4337822d248d5bdbe12ddc
Commit:        ea5ec4ad51e3270b6b4337822d248d5bdbe12ddc
Parent:        b86489843ea1d82430fbf7a9d1e68d9187f6acbe
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 27 23:43:29 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Update the release.nix path in build.sh.

---
 nix/build.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nix/build.sh b/nix/build.sh
index e9aee37..88f6479 100755
--- a/nix/build.sh
+++ b/nix/build.sh
@@ -6,6 +6,6 @@ rm -rf lvm-snapshot
 mkdir lvm-snapshot
 git ls-tree -r HEAD --name-only | xargs cp --parents --target-directory=lvm-snapshot
 tar cvzf lvm-snapshot.tar.gz lvm-snapshot
-nix-build release.nix \
+nix-build nix/ \
     --arg lvm2Src "`pwd`/lvm-snapshot.tar.gz" \
     --arg lvm2Nix `pwd` -A "$@"


