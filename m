From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 11:10:32 -0400
Subject: master - tests: aux.sh use subshell for simple redirection
Message-ID: <201706301510.v5UFAW4C017073@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c31614eccc41746734e712143d0f86c96f95dd4c
Commit:        c31614eccc41746734e712143d0f86c96f95dd4c
Parent:        57779e39eccf456344fa4a51ddfc49cee41a40d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 14:35:42 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 17:08:47 2017 +0200

tests: aux.sh use subshell for simple redirection

---
 test/lib/utils.sh |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 2b5b782..f4c52ad 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -131,9 +131,11 @@ STACKTRACE() {
 
 	# Get backtraces from coredumps
 	if which gdb &>/dev/null; then
-		echo bt full > gdb_commands.txt
-		echo l >> gdb_commands.txt
-		echo quit >> gdb_commands.txt
+		{
+			echo bt full
+			echo l
+			echo quit
+		} > gdb_commands.txt
 		# TODO: use sysctl to get 'core' position in system
 		for i in core*; do
 			test -f "$i" || break   # empty globbing


