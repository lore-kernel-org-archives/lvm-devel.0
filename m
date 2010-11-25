From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:23 +0100
Subject: [PATCH 19/29] Test for error status
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <a1f1654ee3bb7da4b0a538697fc3e60d4a63b63c.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for errors from write and close.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 1a9d40e..ec98c3d 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -181,8 +181,10 @@ static void usage(char *prog, FILE *file)
 static void child_init_signal(int status)
 {
         if (child_pipe[1]) {
-	        write(child_pipe[1], &status, sizeof(status));
-		close(child_pipe[1]);
+		if (write(child_pipe[1], &status, sizeof(status)) < 0)
+			log_sys_error("write", "child_pipe");
+		if (close(child_pipe[1]))
+			log_sys_error("close", "child_pipe");
 	}
 }
 
-- 
1.7.3.2


