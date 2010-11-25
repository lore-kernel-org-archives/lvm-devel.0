From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:09 +0100
Subject: [PATCH 05/29] Test *buf for NULL
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <c243f6bafee4be13671b45b6b0b902d4b158630e.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As we reallocate *buf in CLVMD_CMD_TEST we need to test for NULL
to print status to avoid printing to NULL buffer.
(realloc() == NULL & status != 0)

CHECKME:
General question - what is supposed to be written in *retlen for  *buf == NULL?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 3500ca5..8d1dcff 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -169,7 +169,8 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + snprintf(*buf, buflen, "%s", strerror(status));
+		*retlen = 1 + (*buf) ? snprintf(*buf, buflen, "%s",
+						strerror(status)) : -1;
 	}
 
 	return status;
-- 
1.7.3.2


