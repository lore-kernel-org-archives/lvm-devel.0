From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 Nov 2013 12:05:53 +0000 (UTC)
Subject: master - dmsetup: report error on stderr
Message-ID: <20131101120553.23CAF61028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52f41baedba31335cd16d7767df26378f43c4626
Commit:        52f41baedba31335cd16d7767df26378f43c4626
Parent:        9f6209b878fb5b33dae5bc52a7ea47a9de9ff900
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 12:40:27 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 13:05:03 2013 +0100

dmsetup: report error on stderr

Send error message on stdout, since after _display_info_long()
command return errors.

Patch makes consistent behavior for command:

dmsetup info -c non-existing-dev
&
dmsetup info non-existing-dev

Now both commands report error on stderr when they return error status
for non-existing device.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6742ad4..0f905fd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.83
 ==================================
+  Consistently report on stderr when device is not found for dmsetup info.
   Skip race errors when non-udev dmsetup build runs on udev-enabled system.
   Skip error message when holders are not present in sysfs.
   Use __linux__ instead of linux define to make libdevmapper.h C compliant.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a0ee23e..e25d109 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -461,7 +461,7 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 	uint32_t read_ahead;
 
 	if (!info->exists) {
-		printf("Device does not exist.\n");
+		fprintf(stderr, "Device does not exist.\n");
 		return;
 	}
 


