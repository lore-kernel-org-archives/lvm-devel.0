From: David Teigland <teigland@sourceware.org>
Date: Thu, 10 May 2018 17:26:14 -0400
Subject: master - io: write log header with bcache
Message-ID: <201805102126.w4ALQEHV023424@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ad42e5f068ec9c712724631696afb9eb96bc24b
Commit:        9ad42e5f068ec9c712724631696afb9eb96bc24b
Parent:        d974644db723cb608a2158a3a52b79194817572f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 10 16:25:33 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 10 16:25:33 2018 -0500

io: write log header with bcache

---
 lib/metadata/mirror.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 13e1474..054ca99 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -297,16 +297,17 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!dev_open_quiet(dev))
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open %s/%s to write log header.", lv->vg->name, lv->name);
 		return 0;
+	}
 
-	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), DEV_IO_LV, &log_header)) {
+	if (!dev_write_bytes(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
 		log_error("Failed to write log header to %s.", name);
-		dev_close_immediate(dev);
 		return 0;
 	}
 
-	dev_close_immediate(dev);
+	label_scan_invalidate(dev);
 
 	return 1;
 }


