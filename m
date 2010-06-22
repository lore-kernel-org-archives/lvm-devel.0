From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:58 -0400
Subject: [PATCH 25/35] Make vg->mda_copies persistent in on disk vg metadata.
In-Reply-To: <1277175968-9661-25-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-26-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds the ability to read/write the vg->mda_copies values
from/to the vg metadata.

If we read the VG metadata and this field does not exist, we set
mda_copies to the default value of 0.  Later in the code, we use
this special '0' value to indicate a disable of metadata balancing.
This should preserve existing LVM behavior and ensure metadata balancing
can be turned off should the need arise.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/export.c      |    1 +
 lib/format_text/import_vsn1.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 5f02b5d..52ae11c 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -397,6 +397,7 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(vg->alloc));
 	}
+	outf(f, "metadata_copies = %u", vg->mda_copies);
 
 	return 1;
 }
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 316adb5..62bcbec 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -23,6 +23,7 @@
 #include "pv_alloc.h"
 #include "segtype.h"
 #include "text_import.h"
+#include "defaults.h"
 
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
 			   struct volume_group * vg, struct config_node * pvn,
@@ -745,6 +746,10 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 			return_0;
 	}
 
+	if (!_read_uint32(vgn, "metadata_copies", &vg->mda_copies)) {
+		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
+	}
+
 	/*
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
-- 
1.6.0.6


