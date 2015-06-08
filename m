From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:30 +0800
Subject: [RFC 4/6] Write the device number into metadata
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <1433749712-11837-5-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here we try to write the missing device's major/minor number into
metadata. Fix me if there is other good idea. Otherwise we have to do
the same changes to other kinds metadata format.
---
 lib/format_text/export.c      | 4 ++++
 lib/format_text/import_vsn1.c | 5 +++++
 lib/metadata/pv.h             | 1 +
 3 files changed, 10 insertions(+)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 018772e..be7f06d 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -504,6 +504,10 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 
 		outhint(f, "device = \"%s\"",
 			dm_escape_double_quotes(buffer, pv_dev_name(pv)));
+		if (pv_dev(pv))
+			outhint(f, "dev_t = %u", pv_dev(pv)->dev);
+		else
+			outhint(f, "dev_t = %u", pv->old_dev);
 		outnl(f);
 
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 2d62905..f33c01e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -228,6 +228,11 @@ static int _read_pv(struct format_instance *fid,
 		log_info("Recovering a previously MISSING PV %s with no MDAs.",
 			 pv_dev_name(pv));
 	}
+	if ((pv->status & MISSING_PV) && dm_config_has_node(pvn, "dev_t") &&
+			!_read_uint32(pvn, "dev_t", &pv->old_dev)) {
+		log_error("Couldn't read dev_t for physical volume when it's missing.");
+		return 0;
+	}
 
 	/* Late addition */
 	if (dm_config_has_node(pvn, "dev_size") &&
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 2d436cb..cdd0674 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -26,6 +26,7 @@ struct physical_volume {
 	struct id id;
 	struct id old_id;		/* Set during pvchange -u. */
 	struct device *dev;
+	dev_t old_dev;          /*Only meaningfull when pv is missing*/
 	const struct format_type *fmt;
 	struct format_instance *fid;
 
-- 
1.8.1.4


