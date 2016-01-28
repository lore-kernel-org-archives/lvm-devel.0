From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 28 Jan 2016 15:44:53 +0000 (UTC)
Subject: master - lvmlockd: don't adopt locks from unused lm
Message-ID: <20160128154453.44080606DB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=762b0d697ff7456d0a450121e41eff00cd5a7f08
Commit:        762b0d697ff7456d0a450121e41eff00cd5a7f08
Parent:        0ad40a76c0603147f9b945f7492ad721e7f95edb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 28 09:42:45 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 28 09:42:45 2016 -0600

lvmlockd: don't adopt locks from unused lm

When built without dlm or sanlock support, don't
attempt to adopt locks from that lm.
---
 daemons/lvmlockd/lvmlockd-core.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 4cd3284..292d19c 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -5153,13 +5153,17 @@ static void adopt_locks(void)
 	 * This is expected for at least one of them.
 	 */
 
-	rv = lm_get_lockspaces_dlm(&ls_found);
-	if ((rv < 0) && (rv != -ECONNREFUSED))
-		goto fail;
+	if (lm_support_dlm()) {
+		rv = lm_get_lockspaces_dlm(&ls_found);
+		if ((rv < 0) && (rv != -ECONNREFUSED))
+			goto fail;
+	}
 
-	rv = lm_get_lockspaces_sanlock(&ls_found);
-	if ((rv < 0) && (rv != -ECONNREFUSED))
-		goto fail;
+	if (lm_support_sanlock()) {
+		rv = lm_get_lockspaces_sanlock(&ls_found);
+		if ((rv < 0) && (rv != -ECONNREFUSED))
+			goto fail;
+	}
 
 	if (list_empty(&ls_found)) {
 		log_debug("No lockspaces found to adopt");


