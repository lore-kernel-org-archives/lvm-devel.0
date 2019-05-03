From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 May 2019 15:39:53 -0400
Subject: master - add md component check in vg_read based on size
Message-ID: <201905031939.x43JdrJB006008@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=607858538132a33a27039e0ff4796b1a7d9f4f32
Commit:        607858538132a33a27039e0ff4796b1a7d9f4f32
Parent:        ac627fd1cec77a8334b7e48c3cb8f3efff50fb3c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 2 16:41:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 3 14:39:42 2019 -0500

add md component check in vg_read based on size

If an md component is not excluded by other means and
vg_read is used to read metadata from it, then this new
check compares the device size with the PV size, and runs
a full md check on the device if the sizes don't match.
---
 lib/format_text/import_vsn1.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index c9b9275..79c73ae 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -292,6 +292,18 @@ static int _read_pv(struct format_instance *fid,
 	pv->pe_align = 0;
 	pv->fmt = fid->fmt;
 
+	/*
+	 * It would be nice to check this earlier, e.g. in or after label scan,
+	 * but this is first time we get far enough through the vg metadata to
+	 * see the PV size, and can finally compare it with the device size.
+	 */
+	if (pv->dev && (pv->size != pv->dev->size)) {
+		if (dev_is_md(pv->dev, NULL, 1)) {
+			log_warn("WARNING: device %s is an md component, ignoring PV.", dev_name(pv->dev));
+			return_0;
+		}
+	}
+
 	/* Fix up pv size if missing or impossibly large */
 	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
 		if (!dev_get_size(pv->dev, &pv->size)) {


