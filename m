From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 22:56:03 +0200
Subject: [PATCH 1/4] Remove unused and wrongly set cluster VG flag from clvmd lock query command.
In-Reply-To: <cover.1332708600.git.mbroz@redhat.com>
References: <cover.1332708600.git.mbroz@redhat.com>
Message-ID: <7003cb87166043576b9e727712cd959cdd949c9a.1332708600.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                     |    1 +
 lib/locking/cluster_locking.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e70dc58..93b6440 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.
   Update and fix monitoring of thin pool devices.
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 990e8b1..3e2543b 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -538,7 +538,7 @@ int query_resource(const char *resource, int *mode)
 	strcpy(args + 2, resource);
 
 	args[0] = 0;
-	args[1] = LCK_CLUSTER_VG;
+	args[1] = 0;
 
 	status = _cluster_request(CLVMD_CMD_LOCK_QUERY, node, args, len,
 				  &response, &num_responses);
-- 
1.7.9.1


