From: Eric Ren <zren@suse.com>
Date: Wed, 25 Oct 2017 16:42:41 +0800
Subject: [PATCH] clvmd: don't report error on testing connection
Message-ID: <20171025084241.31511-1-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In HA cluster, we have "clvm" resource agent to manage clvmd daemon.
The agent invokes clvmd like: "clvmd -T90 -d0", which  always prints
a scaring error message:

"""
local socket: connect failed: No such file or directory
"""

When specifed with "-d" option, clvmd tries to check if an instance
of the clvmd daemon is already running through a testing connection.
The connect() will fail with this error, which is expected.

I don't see the necessary to print error on testing connection, so
remove the error.

Signed-off-by: Eric Ren <zren@suse.com>
---
 daemons/clvmd/clvmd.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 5fbcbd7..467facb 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2169,10 +2169,8 @@ static int check_local_clvmd(void)
 	}
 
 	if (connect(local_socket,(struct sockaddr *) &sockaddr,
-		    sizeof(sockaddr))) {
-		log_sys_error("connect", "local socket");
+		    sizeof(sockaddr)))
 		ret = -1;
-	}
 
 	if (close(local_socket))
 		log_sys_error("close", "local socket");
-- 
2.10.2


