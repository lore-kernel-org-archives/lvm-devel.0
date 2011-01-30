From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:36 +0100
Subject: [PATCH 13/24] Memory unlock allows 1 page difference
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <ab9622493e1f52065ae18d1ff78b8976f95e86ad.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As the kernel seems to be doing weird things during
mlock -> munlock -  allow 1 page locking difference without
warning - and log just debug message for a 1 page difference.

Do not scary users too often.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 062b765..9ddc2a2 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -320,9 +320,15 @@ static void _unlock_mem(struct cmd_context *cmd)
 			log_sys_error("close", _procselfmaps);
 		dm_free(_maps_buffer);
 		_maps_buffer = NULL;
-		if (_mstats < unlock_mstats)
-			log_error(INTERNAL_ERROR "Maps lock %ld < unlock %ld",
-				  (long)_mstats, (long)unlock_mstats);
+		if (_mstats < unlock_mstats) {
+			if ((_mstats + 4096) < unlock_mstats)
+				log_error(INTERNAL_ERROR
+					  "Maps lock %ld < unlock %ld",
+					  (long)_mstats, (long)unlock_mstats);
+			else
+				log_debug("Maps lock %ld < unlock %ld, 1 page difference!",
+					  (long)_mstats, (long)unlock_mstats);
+		}
 	}
 
 	if (setpriority(PRIO_PROCESS, 0, _priority))
-- 
1.7.3.5


