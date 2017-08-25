From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:59 -0400
Subject: master - cleanup: easier to read code
Message-ID: <201708251224.v7PCOxtL005111@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8fdc5c0877b137ed3ca1f217d8ef0fa89299a9a
Commit:        c8fdc5c0877b137ed3ca1f217d8ef0fa89299a9a
Parent:        962874bfe2a3c3511e42fe29f0f013c780f65e63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:53:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

cleanup: easier to read code

Split into lines for better reading.
---
 daemons/clvmd/clvmd-command.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index cf19dc2..2971ecb 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -171,8 +171,10 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + ((*buf) ? dm_snprintf(*buf, buflen, "%s",
-						    strerror(status)) : -1);
+		if (*buf)
+			*retlen = dm_snprintf(*buf, buflen, "%s", strerror(status)) + 1;
+		else
+			*retlen = 0;
 	}
 
 	return status;


