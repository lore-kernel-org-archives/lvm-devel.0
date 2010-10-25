From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:34 +0200
Subject: [PATCH 27/30] Instrument compiler about code unreachability
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <a10aa0c9fece5a74e30b068a688fc49979d07381.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Clang needs some instrumentation for code analysis.
It might probably help also for gcc.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 57f7ffe..f9096cc 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -491,6 +491,7 @@ int main(int argc, char *argv[])
 		DEBUGLOG("Can't initialise cluster interface\n");
 		log_error("Can't initialise cluster interface\n");
 		child_init_signal(DFAIL_CLUSTER_IF);
+		__builtin_unreachable();
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
@@ -505,8 +506,10 @@ int main(int argc, char *argv[])
 
 	/* Add the local socket to the list */
 	newfd = malloc(sizeof(struct local_client));
-	if (!newfd)
-	        child_init_signal(DFAIL_MALLOC);
+	if (!newfd) {
+		child_init_signal(DFAIL_MALLOC);
+		__builtin_unreachable();
+	}
 
 	newfd->fd = local_sock;
 	newfd->removeme = 0;
-- 
1.7.3.1


