From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:09:08 +0100
Subject: [PATCH 2/2] Do not send random bytes in message
In-Reply-To: <cover.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
Message-ID: <8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixing few issues:

struct clvm_header contains 'char args[1]' - so adding '+ 1' here
for the message length calculation is not correct - we end up with longer
message where last byte is uninitialized and passed to write function.

xid and clintid are initialized to 0.

Memory allocation is checked for NULL - though it's not really clear what
should happen in this case - so just log the message - probably it will 
fail few moments later...

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 00d330d..ecc366d 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1743,13 +1743,18 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 	}
 
 	/* Add in the size of our header */
-	message_len = message_len + sizeof(struct clvm_header) + 1;
-	replybuf = malloc(message_len);
+	message_len = message_len + sizeof(struct clvm_header);
+	if (!(replybuf = malloc(message_len))) {
+		DEBUGLOG("Memory allocation fails\n");
+		return;
+	}
 
 	clientreply = (struct clvm_header *) replybuf;
 	clientreply->status = status;
 	clientreply->cmd = CLVMD_CMD_REPLY;
 	clientreply->node[0] = '\0';
+	clientreply->xid = 0;
+	clientreply->clientid = 0;
 	clientreply->flags = 0;
 
 	ptr = clientreply->args;
-- 
1.7.4.1


