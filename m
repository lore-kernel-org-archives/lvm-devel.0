From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:21 +0200
Subject: [PATCH 14/30] Fix missing initilisation to 0
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <9fb7596966d9e773570ca7b66ebedfc0b4289fa1.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Missing init value for 'found' which is later tested and may
containe garbage value.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/cmirrord/cluster.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index dddaec9..b6c925a 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -129,7 +129,7 @@ int cluster_send(struct clog_request *rq)
 {
 	int r;
 	int count=0;
-	int found;
+	int found = 0;
 	struct iovec iov;
 	struct clog_cpg *entry;
 
-- 
1.7.3.1


