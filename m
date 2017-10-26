From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Oct 2017 08:05:58 -0400
Subject: master - tests: allow override of LVM_LOG_FILE_MAX_LINES
Message-ID: <201710261205.v9QC5w2i008090@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e80ec892615f9da897da518cb3c55261d2bd51e
Commit:        1e80ec892615f9da897da518cb3c55261d2bd51e
Parent:        04186616bef6789d6f363a1d461c01d344616c7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 26 13:58:43 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 26 14:04:58 2017 +0200

tests: allow override of LVM_LOG_FILE_MAX_LINES

Just like with other vars support this:

make check_local T=xyz LVM_LOG_FILE_MAX_LINES=10000000

Allows easily to override existing line limit.
Also increase limiting size of logs per command since some of
our commands are becoming very verbose....
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a33748d..78bd987 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -84,7 +84,7 @@ RUNNING_DMEVENTD=$(pgrep dmeventd || true)
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 LVM_LOG_FILE_EPOCH=DEBUG
-LVM_LOG_FILE_MAX_LINES=100000
+LVM_LOG_FILE_MAX_LINES=${LVM_LOG_FILE_MAX_LINES-1000000}
 LVM_EXPECTED_EXIT_STATUS=1
 export LVM_LOG_FILE_EPOCH LVM_LOG_FILE_MAX_LINES LVM_EXPECTED_EXIT_STATUS
 


