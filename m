From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:53 +0100
Subject: [PATCH 06/12] Do not zero full 16KB data
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <3593e34fab2806100371d9289ea5301a67cfadbe.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Could be a bit dangerous - so careful review is needed here.

When buffer is passed into ioctl - we always zero at least 16KB with
each ioctl - but it seems only 2 * sizeof(struct dm_ioctl) is
actually needed - this safe quite a few wasted CPU cycles spent
on many ioctl operations.
(could be seen as  micro-optimalization, since the real effect in CPU
 is below reliable measurable treshold for normal use cases.)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index a0fa640..cddd84a 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -960,6 +960,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	size_t len = sizeof(struct dm_ioctl);
 	char *b, *e;
 	int count = 0;
+	size_t min_zero_len = 2 * len;
 
 	for (t = dmt->head; t; t = t->next) {
 		len += sizeof(struct dm_target_spec);
@@ -1011,6 +1012,9 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	if (dmt->geometry)
 		len += strlen(dmt->geometry) + 1;
 
+	if (min_zero_len < len)
+		min_zero_len = len;
+
 	/*
 	 * Give len a minimum size so that we have space to store
 	 * dependencies or status information.
@@ -1022,10 +1026,13 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	while (repeat_count--)
 		len *= 2;
 
-	if (!(dmi = dm_malloc(len)))
+	if (!(dmi = dm_malloc(len))) {
+		log_error("Failed to allocate ioctl buffer.");
 		return NULL;
+	}
 
-	memset(dmi, 0, len);
+	/* Zero@least 2 * sizeof(struct dm_ioctl) */
+	memset(dmi, 0, min_zero_len);
 
 	version = &_cmd_data_v4[dmt->type].version;
 
-- 
1.7.7.3


