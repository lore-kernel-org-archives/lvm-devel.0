From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 16:39:08 +0000 (UTC)
Subject: master - tests: correct test condition
Message-ID: <20140414163908.92AFD610E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c82a37aee6ff266145bd2dd865763adf4f7187a
Commit:        3c82a37aee6ff266145bd2dd865763adf4f7187a
Parent:        92ee51a4c367848fc17ab79848bf5ab7fb1de678
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 14 14:55:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 14:55:14 2014 +0200

tests: correct test condition

Abort loop when PIDFILE is gone
---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 26f1d74..b827632 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -53,7 +53,7 @@ if test -e LOCAL_CLVMD ; then
 	kill $(cat LOCAL_CLVMD)
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Shutdown of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" && break
+		test -e "$CLVMD_PIDFILE" || break
 		sleep .1
 	done # wait for the pid removal
 	aux prepare_clvmd


