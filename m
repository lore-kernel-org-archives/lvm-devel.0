From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Jun 2016 21:04:25 +0000 (UTC)
Subject: master - vgcfgrestore: check for missing device
Message-ID: <20160620210425.5A9F960DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f96de674905cd9f109cd19e03ba5e92ac84104b8
Commit:        f96de674905cd9f109cd19e03ba5e92ac84104b8
Parent:        47a29f6b2eb78a71ba6eafa9f47c7519a629155f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 20 16:02:07 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 20 16:02:07 2016 -0500

vgcfgrestore: check for missing device

The missing device will generally be seen earlier
and cause the command to not reach this point, but
check anyway for completeness.
---
 lib/format_text/archiver.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e6d4b59..92799e4 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -339,6 +339,11 @@ static int _restore_vg_should_write_pv(struct physical_volume *pv, int do_pvcrea
 	if (!(pv->fmt->features & FMT_PV_FLAGS))
 		return 0;
 
+	if (!pv->dev) {
+		log_error("Failed to find device for PV.");
+		return -1;
+	}
+
 	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return -1;


