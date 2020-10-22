From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:17 +0000 (GMT)
Subject: master - add label_scan_devs_cached
Message-ID: <20201022204317.D80F33851C09@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7f195b7e8f27c292761c604c1697c1d97cd5c1d
Commit:        a7f195b7e8f27c292761c604c1697c1d97cd5c1d
Parent:        677f829e540ef0f2fa2781f4facc7571dee1fb83
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 12:20:17 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

add label_scan_devs_cached

label_scan_devs without invalidating data first
for cases where the caller wants to use any
bcache data they have already read.
---
 lib/label/label.c | 15 +++++++++++++++
 lib/label/label.h |  1 +
 2 files changed, 16 insertions(+)

diff --git a/lib/label/label.c b/lib/label/label.c
index bc8e60fc9..36eab19f3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1302,6 +1302,21 @@ int label_read_pvid(struct device *dev)
 	return 1;
 }
 
+/*
+ * label_scan_devs without invalidating data for the devs first,
+ * when the caller wants to make use of any bcache data that
+ * they may have already read.
+ */
+int label_scan_devs_cached(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs)
+{
+	if (!scan_bcache)
+		return 0;
+
+	_scan_list(cmd, f, devs, NULL);
+
+	return 1;
+}
+
 /*
  * Scan and cache lvm data from the listed devices.  If a device is already
  * scanned and cached, this replaces the previously cached lvm data for the
diff --git a/lib/label/label.h b/lib/label/label.h
index ddfb34af5..a98ba32e3 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -104,6 +104,7 @@ extern struct bcache *scan_bcache;
 
 int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
+int label_scan_devs_cached(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
 int label_scan_dev(struct device *dev);


