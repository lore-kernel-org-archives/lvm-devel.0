From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:08:52 +0000 (UTC)
Subject: master - report: detect dev_get_size failure
Message-ID: <20131122200852.99FDB60EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a50a297f6e75d650abe9fe084b499a7968cc59ee
Commit:        a50a297f6e75d650abe9fe084b499a7968cc59ee
Parent:        08d6d81cc24a3c3b780fe25ed49aefc9a9b61586
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:21:52 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:54:16 2013 +0100

report: detect dev_get_size failure

Since dev_get_size() may fail, detect this failure.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |    7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b7a1e84..99f9067 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Check for failure of dev_get_size() when reporting device size.
   Drop extra unneeded '/' when scanning sysfs directory.
   Fix undef value if skipped clustered VG ignored for toollib PV seg. (2.02.103)
   liblvm/python API Add ability to validate VG/LV names.
diff --git a/lib/report/report.c b/lib/report/report.c
index 9cb2298..20eab4f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -693,8 +693,11 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	uint64_t size = 0;
-	dev_get_size(*(const struct device **) data, &size);
+	uint64_t size;
+
+	if (!dev_get_size(*(const struct device **) data, &size))
+		return_0;
+
 	return _size64_disp(rh, mem, field, &size, private);
 }
 


