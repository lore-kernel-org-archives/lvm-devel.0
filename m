From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:04 +0200
Subject: [PATCH 09/23] Replicator: extend volume_group with list of VGs
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <40df03334e6ec33a2b5e7fcce2a481d603a68926.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add pointer to linked list of opened VGs. List temporarily keeps
the information about needed or locked and opened VGs for replicator target.
Also add cmd_missing_vgs status information for quick check and
also for possible continuos process_each_lv() where we need
to detect whether failure has been caused by missing VG or
some other reason.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 37588aa..da1a230 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -223,6 +223,8 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct dm_list *cmd_vgs;	/* List of wanted/locked and opened VGs */
+	uint32_t cmd_missing_vgs;
 	uint32_t seqno;		/* Metadata sequence number */
 
 	alloc_policy_t alloc;
-- 
1.7.0.1


