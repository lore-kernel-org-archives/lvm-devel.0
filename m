From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:31 +0000 (UTC)
Subject: master - conf: regenerate example.conf.in
Message-ID: <20160303132031.6BF5560310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ab111016470d694abf8bbd89df0360061f2736e
Commit:        0ab111016470d694abf8bbd89df0360061f2736e
Parent:        ff6e124a338d1dbdde3b6280784d599e504378ef
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:31:29 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

conf: regenerate example.conf.in

---
 conf/example.conf.in |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 60f8023..975f514 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1426,6 +1426,22 @@ activation {
 	# This configuration option has an automatic default value.
 	# check_pv_device_sizes = 1
 
+	# Configuration option metadata/record_lvs_history.
+	# When enabled, LVM keeps history records about removed LVs in
+	# metadata. The information that is recorded in metadata for
+	# historical LVs is reduced when compared to original
+	# information kept in metadata for live LVs. Currently, this
+	# feature is supported for thin and thin snapshot LVs only.
+	# This configuration option has an automatic default value.
+	# record_lvs_history = 0
+
+	# Configuration option metadata/lvs_history_retention_time.
+	# Retention time in seconds after which a record about individual
+	# historical logical volume is automatically destroyed.
+	# A value of 0 disables this feature.
+	# This configuration option has an automatic default value.
+	# lvs_history_retention_time = 0
+
 	# Configuration option metadata/pvmetadatacopies.
 	# Number of copies of metadata to store on each PV.
 	# The --pvmetadatacopies option overrides this setting.


