From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:38 -0400
Subject: master - tests: use luks1 for test
Message-ID: <201905031118.x43BIcps028370@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac627fd1cec77a8334b7e48c3cb8f3efff50fb3c
Commit:        ac627fd1cec77a8334b7e48c3cb8f3efff50fb3c
Parent:        8c56e31134baa5e7ddf8881e8a23d5ac5f2459a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 13:11:09 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

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


