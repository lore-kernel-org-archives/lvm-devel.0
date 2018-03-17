From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:35:10 -0400
Subject: master - cleanup: use zalloc
Message-ID: <201803172235.w2HMZAAP011297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c82ab92d04acec41f9a3550e2ee7970d3937566e
Commit:        c82ab92d04acec41f9a3550e2ee7970d3937566e
Parent:        5c40e81a7e6a42e40a49c89758f8e9fd269de8d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:14:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

cleanup: use zalloc

Replace malloc() + memset()   with zalloc().
---
 daemons/lvmetad/lvmetad-core.c |    4 +---
 libdm/datastruct/hash.c        |    8 +++-----
 libdm/ioctl/libdm-iface.c      |    4 +---
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 66a6b82..f4f5f42 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2528,10 +2528,8 @@ inval:
 
 	info = dm_hash_lookup(s->vgid_to_info, uuid);
 	if (!info) {
-		info = malloc(sizeof(struct vg_info));
-		if (!info)
+		if (!(info = dm_zalloc(sizeof(struct vg_info))))
 			goto bad;
-		memset(info, 0, sizeof(struct vg_info));
 		if (!dm_hash_insert(s->vgid_to_info, uuid, (void*)info))
 			goto bad;
 	}
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 6df3efe..fb153ce 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -102,11 +102,9 @@ struct dm_hash_table *dm_hash_create(unsigned size_hint)
 
 	hc->num_slots = new_size;
 	len = sizeof(*(hc->slots)) * new_size;
-	if (!(hc->slots = dm_malloc(len))) {
-		stack;
-		goto bad;
-	}
-	memset(hc->slots, 0, len);
+	if (!(hc->slots = dm_zalloc(len)))
+		goto_bad;
+
 	return hc;
 
       bad:
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 8bee24b..3965be6 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1156,11 +1156,9 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	while (repeat_count--)
 		len *= 2;
 
-	if (!(dmi = dm_malloc(len)))
+	if (!(dmi = dm_zalloc(len)))
 		return NULL;
 
-	memset(dmi, 0, len);
-
 	version = &_cmd_data_v4[dmt->type].version;
 
 	dmi->version[0] = (*version)[0];


