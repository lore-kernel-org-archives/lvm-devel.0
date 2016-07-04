From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:42:04 +0000 (UTC)
Subject: master - tests: add line for mixing dmeventd with log
Message-ID: <20160704154204.1908360E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2063d6bb0640c54d0356dff3618a1239357a55ae
Commit:        2063d6bb0640c54d0356dff3618a1239357a55ae
Parent:        b91390c21149875c26f8c7b37e3cbdfda0f419ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 17:32:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:41:09 2016 +0200

tests: add line for mixing dmeventd with log

TODO: it might be better to log dmeventd messages with test output
just like we do with clvmd - maybe we will switch to this one
instead of extra  DMEVENTD log file in future....
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 66574df..7724723 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -194,6 +194,7 @@ prepare_dmeventd() {
 
 	local run_valgrind=
 	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
+#	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" 2>&1 &
 	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -fddddl "$@" >debug.log_DMEVENTD_out 2>&1 &
 	echo $! > LOCAL_DMEVENTD
 


