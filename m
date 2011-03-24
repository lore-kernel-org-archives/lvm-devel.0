From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 12:16:36 +0100
Subject: [PATCH 3/4] Another fix for garbage send in clvmd message
In-Reply-To: <cover.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
Message-ID: <b9919298acd0f83e1cac3a43bd78164f8dece828.1300965223.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(Similar to my 2 other previous already posted patches).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/refresh_clvmd.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/refresh_clvmd.c b/daemons/clvmd/refresh_clvmd.c
index 1e88b5c..805fbe3 100644
--- a/daemons/clvmd/refresh_clvmd.c
+++ b/daemons/clvmd/refresh_clvmd.c
@@ -154,6 +154,7 @@ static void _build_header(struct clvm_header *head, int cmd, const char *node,
 	head->cmd = cmd;
 	head->status = 0;
 	head->flags = 0;
+	head->xid = 0;
 	head->clientid = 0;
 	head->arglen = len;
 
@@ -197,11 +198,11 @@ static int _cluster_request(char cmd, const char *node, void *data, int len,
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, cmd, node, len);
+	_build_header(head, cmd, node, len - 1);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			       strlen(head->node) + len, &retbuf, no_response);
+			       strlen(head->node) + len - 1, &retbuf, no_response);
 	if (!status || no_response)
 		goto out;
 
-- 
1.7.4.1


