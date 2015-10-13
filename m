From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:41 +0000 (UTC)
Subject: master - tests: start logging dmeventd output
Message-ID: <20151013140441.3EA2F6017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4cc5eabfe722daf88d19b60d58c616c31e57edd
Commit:        c4cc5eabfe722daf88d19b60d58c616c31e57edd
Parent:        8cc21354c2b4cb58223950b7e089eb28e602f0e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:44:08 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:21 2015 +0200

tests: start logging dmeventd output

Log dmeventd output from test - keep output logging in test
and avoid sending messages to syslog.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 56316f7..8a25d87 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -70,7 +70,7 @@ prepare_dmeventd() {
 
 	local run_valgrind=
 	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
-	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -f "$@" &
+	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" >debug.log_DMEVENTD_out 2>&1 &
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead


