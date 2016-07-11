From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Jul 2016 13:48:02 +0000 (UTC)
Subject: master - tests: increase max lines for clvmd
Message-ID: <20160711134802.6A58160CB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8756297a8d39d33766f1f19060749b9570d76b1a
Commit:        8756297a8d39d33766f1f19060749b9570d76b1a
Parent:        34c55d98eefd88f85476c0f62f0649c706bde6f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 14:45:25 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 14:45:25 2016 +0200

tests: increase max lines for clvmd

Clvmd is a bit more verbose long time running process so
let it live with more logged lines.

Also fix typo in warn message from last commit.
---
 lib/log/log.c   |    2 +-
 test/lib/aux.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 434b8d0..6d5fc59 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -116,7 +116,7 @@ void init_log_file(const char *log_file, int append)
 
 		if ((env = getenv("LVM_LOG_FILE_MAX_LINES"))) {
 			if (sscanf(env, FMTu64, &_log_file_max_lines) != 1) {
-				log_warn("WARNING: Ingnoring incorrect LVM_LOG_MAX_LINES envvar \"%s\".", env);
+				log_warn("WARNING: Ignoring invalid LVM_LOG_MAX_LINES envvar \"%s\".", env);
 				_log_file_max_lines = 0;
 			}
 			_log_file_lines = 0;
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7724723..90f2ab1 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -169,7 +169,7 @@ prepare_clvmd() {
 	rm -f "$CLVMD_PIDFILE"
 	echo "<======== Starting CLVMD ========>"
 	# lvs is executed from clvmd - use our version
-	LVM_LOG_FILE_EPOCH=CLVMD LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
+	LVM_LOG_FILE_EPOCH=CLVMD LVM_LOG_FILE_MAX_LINES=1000000 LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in {1..100} ; do


