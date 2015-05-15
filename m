From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:12 +0000 (UTC)
Subject: master - lvmpolld: label known return codes
Message-ID: <20150515183712.5E42A610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=333fdfd4b69d04ff94eca644d335567dd70bc589
Commit:        333fdfd4b69d04ff94eca644d335567dd70bc589
Parent:        8d594c409c33884a00be578543589d8207338413
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 15:53:29 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:31:48 2015 +0200

lvmpolld: label known return codes

so that lvmpolld-client can decode and describe these
return codes properly
---
 daemons/lvmpolld/lvmpolld-core.c     |    4 ++--
 daemons/lvmpolld/lvmpolld-protocol.h |    3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index ede6fc2..ad6f5f7 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -397,11 +397,11 @@ static void *fork_and_poll(void *args)
 
 		if ((dup2(outfd, STDOUT_FILENO ) != STDOUT_FILENO) ||
 		    (dup2(errfd, STDERR_FILENO ) != STDERR_FILENO))
-			_exit(100);
+			_exit(LVMPD_RET_DUP_FAILED);
 
 		execve(*(pdlv->cmdargv), (char *const *)pdlv->cmdargv, (char *const *)pdlv->cmdenvp);
 
-		_exit(101);
+		_exit(LVMPD_RET_EXC_FAILED);
 	} else {
 		/* parent */
 		if (r == -1) {
diff --git a/daemons/lvmpolld/lvmpolld-protocol.h b/daemons/lvmpolld/lvmpolld-protocol.h
index 7d9821b..1f0d6a6 100644
--- a/daemons/lvmpolld/lvmpolld-protocol.h
+++ b/daemons/lvmpolld/lvmpolld-protocol.h
@@ -46,4 +46,7 @@
 #define LVMPD_REAS_RETCODE	"retcode" /* lvm cmd ret code */
 #define LVMPD_REAS_SIGNAL	"signal" /* lvm cmd terminating singal */
 
+#define LVMPD_RET_DUP_FAILED	100
+#define LVMPD_RET_EXC_FAILED	101
+
 #endif /* _LVM_LVMPOLLD_PROTOCOL_H */


