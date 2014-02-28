From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:14 +0000 (UTC)
Subject: master - NIX: Add a local nix-build.sh script.
Message-ID: <20140228102614.6620060F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c99601267072a6d9b8e418f860b7b6726eb9561
Commit:        2c99601267072a6d9b8e418f860b7b6726eb9561
Parent:        fb2c6fffe15620e4c26e6a108ab2ff82b035a4b4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jan 23 16:42:54 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Add a local nix-build.sh script.

---
 nix-build.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/nix-build.sh b/nix-build.sh
new file mode 100755
index 0000000..e9aee37
--- /dev/null
+++ b/nix-build.sh
@@ -0,0 +1,11 @@
+#!/bin/sh
+set -ex
+rm -f result
+rm -f divine-snapshot.tar.gz
+rm -rf lvm-snapshot
+mkdir lvm-snapshot
+git ls-tree -r HEAD --name-only | xargs cp --parents --target-directory=lvm-snapshot
+tar cvzf lvm-snapshot.tar.gz lvm-snapshot
+nix-build release.nix \
+    --arg lvm2Src "`pwd`/lvm-snapshot.tar.gz" \
+    --arg lvm2Nix `pwd` -A "$@"


