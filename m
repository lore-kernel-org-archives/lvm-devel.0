From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:58 -0500
Subject: master - debug: add stack tracking
Message-ID: <201802122120.w1CLKw6q023782@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e40768ac32e6de5e6f9614ae0ad702c93a4e1330
Commit:        e40768ac32e6de5e6f9614ae0ad702c93a4e1330
Parent:        27399755fd1b1292cc93f6469162c0855b7231c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 8 11:03:06 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:15:03 2018 +0100

debug: add stack tracking

---
 lib/locking/cluster_locking.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index e2f8123..038f6b6 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -211,11 +211,10 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 
 	*num = 0;
 
-	if (_clvmd_sock == -1)
-		_clvmd_sock = _open_local_sock(0);
-
-	if (_clvmd_sock == -1)
-		return 0;
+	if (_clvmd_sock == -1) {
+		if ((_clvmd_sock = _open_local_sock(0)) == -1)
+			return_0;
+	}
 
 	/* 1 byte is used from struct clvm_header.args[1], so -> len - 1 */
 	_build_header(head, clvmd_cmd, node, len - 1);
@@ -224,7 +223,7 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
 			      strlen(head->node) + len - 1, &retbuf);
 	if (!status)
-		goto out;
+		goto_out;
 
 	/* Count the number of responses we got */
 	head = (struct clvm_header *) retbuf;
@@ -245,7 +244,7 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 	if (!(rarray = dm_malloc(sizeof(lvm_response_t) * num_responses))) {
 		errno = ENOMEM;
 		status = 0;
-		goto out;
+		goto_out;
 	}
 
 	/* Unpack the response into an lvm_response_t array */
@@ -267,7 +266,7 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 			dm_free(rarray);
 			errno = ENOMEM;
 			status = 0;
-			goto out;
+			goto_out;
 		}
 
 		strcpy(rarray[i].response, inptr);


