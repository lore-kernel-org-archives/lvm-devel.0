From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:15 +0100
Subject: [PATCH 01/11] Add mda_slots field for PV info in the cache.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-2-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The code further needs to access the information about metadata areas
directly quite often without checking the relative position to other
metadata areas or data areas. IOW, we need to know directly whether
there is any metadata area at the start of the disk or at the end of the
disk or any other position we can think of in the future. This way, I
know exactly which slots are free, which are occupied and I know the
relative position to other metadata areas without checking any offsets
etc.

Using the original list would be quite painful here - either I'd need to
store the position somewhere or I'll just use this array which seems
better. Though, the list itself is still there - this is something I'd
like to discuss... (So I haven't tried to remove the mda_list completely
yet).

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/cache/lvmcache.c |    1 +
 lib/cache/lvmcache.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 60edcec..d1b6dea 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1357,6 +1357,7 @@ static void _lvmcache_destroy_entry(struct lvmcache_info *info)
 	_vginfo_detach_info(info);
 	strcpy(info->dev->pvid, "");
 	label_destroy(info->label);
+	dm_free(info->mda_slots);
 	dm_free(info);
 }
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 28f8541..32b4579 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -33,6 +33,7 @@
 struct cmd_context;
 struct format_type;
 struct volume_group;
+struct metadata_area;
 
 /* One per VG */
 struct lvmcache_vginfo {
@@ -53,6 +54,7 @@ struct lvmcache_vginfo {
 struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
 	struct dm_list mdas;	/* list head for metadata areas */
+	void **mda_slots;	/* Direct indexed access for metadata areas */
 	struct dm_list das;	/* list head for data areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label;
-- 
1.7.3.2


