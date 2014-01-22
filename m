From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 22 Jan 2014 15:32:15 +0000 (UTC)
Subject: master - wiping: issue error if libblkid detects signature and fails to return offset/length
Message-ID: <20140122153215.88EFA61673@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b9d25133e3dfa0f95f838a75a682e5195110684
Commit:        2b9d25133e3dfa0f95f838a75a682e5195110684
Parent:        cb595a5a13134cd3c12559e5e3b69f4ecf667c18
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 22 16:26:49 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 22 16:29:52 2014 +0100

wiping: issue error if libblkid detects signature and fails to return offset/length

We need both offset and length when trying to wipe detected signatures.
The libblkid can fail so it's good to have an error message issued for
this state instead of being silent (libblkid does not issue any error
messages here). We just issued "stack" here before but that was not
quite useful if some error occurs...
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |   24 ++++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bbf736e..73f716c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Issue error if libbblkid detects signature and fails to return offset/length.
   Update autoconf config.guess/sub to 2014-01-01.
   Online thin pool metadata resize requires 1.10 kernel thin pool target.
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 78b093c..e67169b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -452,6 +452,8 @@ out:
 static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       int exclude_lvm_member, int yes, force_t force)
 {
+	static const char* msg_failed_offset = "Failed to get offset of the %s signature on %s.";
+	static const char* msg_failed_length = "Failed to get length of the %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;
@@ -461,13 +463,23 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		if (exclude_lvm_member &&
 		    (!strcmp(type, "LVM1_member") || !strcmp(type, "LVM2_member")))
 			return 1;
-		if (!blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL) &&
-		     blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len))
-			return_0;
+		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
+			log_error(msg_failed_offset, type, name);
+			return 0;
+		}
+		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
+			log_error(msg_failed_length, type, name);
+			return 0;
+		}
 	} else if (!blkid_probe_lookup_value(probe, "PTTYPE", &type, NULL)) {
-		if (!blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL) &&
-		     blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len))
-			return_0;
+		if (blkid_probe_lookup_value(probe, "PTMAGIC_OFFSET", &offset, NULL)) {
+			log_error(msg_failed_offset, type, name);
+			return 0;
+		}
+		if (blkid_probe_lookup_value(probe, "PTMAGIC", &magic, &len)) {
+			log_error(msg_failed_length, type, name);
+			return 0;
+		}
 		usage = "partition table";
 	} else
 		return_0;


