From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:35 +0200
Subject: [PATCH 01/22] Add units to passed parameters data & timeout Use size
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <ce72aa1e436dc4981e07ce04c9e0c87b656009b6.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index fac9d21..ff714d9 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1520,11 +1520,11 @@ static int _replicator_emit_segment_line(const struct load_segment *seg, char *p
 			    (rsite->mode == DM_REPLICATOR_SYNC) ? "synchronous" : "asynchronous");
 
 		if (rsite->fall_behind_data)
-			EMIT_PARAMS(*pos, " data %" PRIu64, rsite->fall_behind_data);
+			EMIT_PARAMS(*pos, " size %" PRIu64 "s", rsite->fall_behind_data);
 		else if (rsite->fall_behind_ios)
 			EMIT_PARAMS(*pos, " ios %" PRIu32, rsite->fall_behind_ios);
 		else if (rsite->async_timeout)
-			EMIT_PARAMS(*pos, " timeout %" PRIu32, rsite->async_timeout);
+			EMIT_PARAMS(*pos, " timeout %" PRIu32 "s", rsite->async_timeout);
 	}
 
 	return 1;
-- 
1.7.1.1


