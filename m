From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:19 +0100
Subject: [PATCH 15/29] Modify test to catch passing NULL pointer
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <21ce9b1c3b783c65154252d32f13058c6c99b567.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reason for this change is to avoid passing NULL 'data' to
_add_pv_to_list().

'data' is initialized as NULL and if 'dev' would be NULL from info->dev
'data' assignement would skipped and NULL would be passed through.
Also it would not make big sence to pass 'data' pointer twice in case
'dev' would be NULL.

Another fix could be that 'dev' could never be NULL in this place - so
the test could be to completely removed?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/disk-rep.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index bc58744..071b39d 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -471,7 +471,7 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 	    vginfo->infos.n) {
 		dm_list_iterate_items(info, &vginfo->infos) {
 			dev = info->dev;
-			if (dev && !(data = read_disk(fmt, dev, mem, vg_name)))
+			if (!dev || !(data = read_disk(fmt, dev, mem, vg_name)))
 				break;
 			_add_pv_to_list(head, data);
 		}
-- 
1.7.3.2


