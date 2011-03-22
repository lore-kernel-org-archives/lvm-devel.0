From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:11 +0100
Subject: [PATCH 2/8] Fix sending random content in the cluster message
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <3f50dfed411cbb8dff98a06fcce7971b56b35ca8.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another one to make the passed messages around cluster more consistent.
Initilize missing header part.
And compensate 1 extra byte attached to the message without right
content.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/cluster_locking.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 4dac05f..074f145 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -173,6 +173,7 @@ static void _build_header(struct clvm_header *head, int clvmd_cmd, const char *n
 	head->cmd = clvmd_cmd;
 	head->status = 0;
 	head->flags = 0;
+	head->xid = 0;
 	head->clientid = 0;
 	head->arglen = len;
 
@@ -216,11 +217,12 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, clvmd_cmd, node, len);
+	/* 1 byte is used from struct  clmd_header.argc[1], so -> len - 1 */
+	_build_header(head, clvmd_cmd, node, len - 1);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			      strlen(head->node) + len, &retbuf);
+			      strlen(head->node) + len - 1, &retbuf);
 	if (!status)
 		goto out;
 
-- 
1.7.4.1


