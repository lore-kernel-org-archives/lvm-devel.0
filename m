From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:07:39 -0500
Subject: master - device_mapper: fix incorrect dm_strncpy usage
Message-ID: <201812010007.wB107drn031146@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c61c4271a4d9cc990f19614d1d2e7d203d57ebfd
Commit:        c61c4271a4d9cc990f19614d1d2e7d203d57ebfd
Parent:        6a4a6a7cd7ef83b6283284637e3b28476fbc7712
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 00:41:24 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:04:27 2018 +0100

device_mapper: fix incorrect dm_strncpy usage

Patch 668c9d0762fc6736a1e9372785544eda6a939806 introduced regression,
since the code here would actually always return failing result.
Replace it with more simple call to strndup().
---
 device_mapper/vdo/status.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 53dfe4d..40e69ba 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -203,16 +203,11 @@ bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
 		goto bad;
 	}
 
-	if (!(s->device = (!mem) ? malloc((e - b) + 1) : dm_pool_alloc(mem, (e - b) + 1))) {
+	if (!(s->device = (!mem) ? strndup(b, (te - b)) : dm_pool_alloc(mem, (te - b)))) {
 		_set_error(result, "out of memory");
 		goto bad;
 	}
 
-	if (!dm_strncpy(s->device, b, te - b + 1)) {
-		_set_error(result, "copy device");
-		goto bad;
-	}
-
 	b = _eat_space(te, e);
 
 #define XX(p, f, fn) if (!_parse_field(&b, e, p, f, fn, result)) goto bad;


