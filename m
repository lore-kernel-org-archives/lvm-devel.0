From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:34 +0000 (UTC)
Subject: master - pv: _pvcreate_write: do label removal and zeroing only if creating a new PV
Message-ID: <20160215120834.0FEDE60509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6e3080fff7f101f2bbec21a7757e54e6026d61d
Commit:        b6e3080fff7f101f2bbec21a7757e54e6026d61d
Parent:        73f1d444c8fccf7f0c95d09ff4b2a6c9f0e40e02
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 12 15:18:52 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

pv: _pvcreate_write: do label removal and zeroing only if creating a new PV

---
 lib/metadata/metadata.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 90643fa..7af545a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1637,32 +1637,33 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 
 static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
-	int zero = pvw->pp ? pvw->pp->zero : 1;
 	struct physical_volume *pv = pvw->pv;
 	struct device *dev = pv->dev;
 	const char *pv_name = dev_name(dev);
 
-	/* Wipe existing label first */
-	if (!label_remove(pv_dev(pv))) {
-		log_error("Failed to wipe existing label on %s", pv_name);
-		return 0;
-	}
-
-	if (zero) {
-		log_verbose("Zeroing start of device %s", pv_name);
-		if (!dev_open_quiet(dev)) {
-			log_error("%s not opened: device not zeroed", pv_name);
+	if (pvw->new_pv) {
+		/* Wipe existing label first */
+		if (!label_remove(pv_dev(pv))) {
+			log_error("Failed to wipe existing label on %s", pv_name);
 			return 0;
 		}
 
-		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
-			log_error("%s not wiped: aborting", pv_name);
+		if (pvw->pp->zero) {
+			log_verbose("Zeroing start of device %s", pv_name);
+			if (!dev_open_quiet(dev)) {
+				log_error("%s not opened: device not zeroed", pv_name);
+				return 0;
+			}
+
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+				log_error("%s not wiped: aborting", pv_name);
+				if (!dev_close(dev))
+					stack;
+				return 0;
+			}
 			if (!dev_close(dev))
 				stack;
-			return 0;
 		}
-		if (!dev_close(dev))
-			stack;
 	}
 
 	log_verbose("Writing physical volume data to disk \"%s\"",


