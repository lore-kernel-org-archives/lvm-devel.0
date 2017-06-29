From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:54 -0400
Subject: master - vgimportclone.sh: no mixing string and array
Message-ID: <201706292026.v5TKQsJV026542@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96a2e0024070ee35d68cf0beeeed283bf74318ab
Commit:        96a2e0024070ee35d68cf0beeeed283bf74318ab
Parent:        4d34bc65dd05beb734c8ae65b86a11b37c3c2c94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 19:40:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: no mixing string and array

Argument mixes string and array. Use * or separate argument.
---
 scripts/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index d5b62a8..da79591 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -29,7 +29,7 @@ LVM="${LVM_BINARY:-lvm}"
 
 die() {
     code=$1; shift
-    echo "Fatal: $@" 1>&2
+    echo "Fatal:" "$@" 1>&2
     exit $code
 }
 


