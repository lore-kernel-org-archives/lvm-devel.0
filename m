From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 04:34:14 -0400
Subject: master - vdo: fix parsing vdo status
Message-ID: <201807090834.w698YEZE024625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5cf0923e1840375d23c4fd6035b919613ce6573b
Commit:        5cf0923e1840375d23c4fd6035b919613ce6573b
Parent:        e9d1f676b3768844471f8c6d3345a1b60bc2c94e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 00:54:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 10:30:34 2018 +0200

vdo: fix parsing vdo status

Recent updates relay on zerod status structure memory (device ptr is
NULL) and also dm_strncpy need to count with '\0'.
---
 device_mapper/vdo/status.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 7323a35..a0eba49 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -188,7 +188,7 @@ bool vdo_status_parse(struct dm_pool *mem, const char *input,
 	const char *te;
 	struct vdo_status *s;
 
-	s = (!mem) ? malloc(sizeof(*s)) : dm_pool_zalloc(mem, sizeof(*s));
+	s = (!mem) ? zalloc(sizeof(*s)) : dm_pool_zalloc(mem, sizeof(*s));
 
 	if (!s) {
 		_set_error(result, "out of memory");
@@ -206,7 +206,7 @@ bool vdo_status_parse(struct dm_pool *mem, const char *input,
 		_set_error(result, "out of memory");
 		goto bad;
 	}
-	dm_strncpy(s->device, b, te - b);
+	dm_strncpy(s->device, b, te - b + 1);
 
 	b = _eat_space(te, e);
 


