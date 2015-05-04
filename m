From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 08:21:28 +0000 (UTC)
Subject: master - tests: check for clvmd process entry
Message-ID: <20150504082128.EB23860F2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c90ee0414d74ddbaabf270c306acd4fef76718b5
Commit:        c90ee0414d74ddbaabf270c306acd4fef76718b5
Parent:        3f05e662bbb0a02315e3ef806543fd3e092f40f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 10:16:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 10:16:33 2015 +0200

tests: check for clvmd process entry

Instead of checking just for pid file - rather check
for process  - since there could be slight race, the
pid file is gone, but process still exists.
---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index db87d52..e1408bf 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -69,7 +69,7 @@ if test -e LOCAL_CLVMD ; then
 	kill $(< LOCAL_CLVMD)
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Shutdown of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" || break
+		pgrep clvmd || break
 		sleep .1
 	done # wait for the pid removal
 	aux prepare_clvmd


