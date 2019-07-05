From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:31 -0400
Subject: stable-2.02 - tests: use luks1 for test
Message-ID: <201907052326.x65NQVJl009751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e9c409a3eef3c18f97b70a3d679ea24a2458886
Commit:        1e9c409a3eef3c18f97b70a3d679ea24a2458886
Parent:        e1cc409ae6808cd00b908756b53a4d58338aa5f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 13:11:09 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

tests: use luks1 for test

Since we do not need anywhere luks2 - pick older format
which does not require password for resize to keep
the rest of test unmodified.
---
 test/shell/fsadm-crypt.sh |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index d90413d..9c85edf 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -46,7 +46,14 @@ PWD2="mymJeD8ivEhE"
 PWD3="ocMakf3fAcQO"
 SKIP_DETACHED=
 
-which cryptsetup || check_cryptsetup=${check_cryptsetup:-cryptsetup}
+if which cryptsetup ; then
+	# use older format luks1 - otherwise the test would need to pass password everywhere...
+	case $(cryptsetup --version) in
+	"cryptsetup 2"*)  FORMAT_PARAMS="$FORMAT_PARAMS --type luks1" ;;
+	esac
+else
+	check_cryptsetup=${check_cryptsetup:-cryptsetup}
+fi
 
 which mkfs.ext2 || check_ext2=${check_ext2:-mkfs.ext2}
 which mkfs.ext3 || check_ext3=${check_ext3:-mkfs.ext3}


