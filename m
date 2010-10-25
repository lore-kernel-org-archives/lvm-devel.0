From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:22 +0200
Subject: [PATCH 15/30] Function pull_state cannot work with NULL buffer
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <abdcbbaa1bdc75655773af22a50db6ff0e1e8539.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In practice this situation should not happen in current lvm code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/cmirrord/functions.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index e5da757..58e76ac 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -1809,8 +1809,10 @@ int pull_state(const char *uuid, uint64_t luid,
 	int bitset_size;
 	struct log_c *lc;
 
-	if (!buf)
+	if (!buf) {
 		LOG_ERROR("pull_state: buf == NULL");
+		return -EINVAL;
+	}
 
 	lc = get_log(uuid, luid);
 	if (!lc) {
-- 
1.7.3.1


