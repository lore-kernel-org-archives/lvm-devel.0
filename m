From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:33 +0000 (GMT)
Subject: main - cov: ensure bufffe size is at least 5
Message-ID: <20210727225033.11300383B82C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4994915015498bc0382fc6624d2f843f865ae51
Commit:        d4994915015498bc0382fc6624d2f843f865ae51
Parent:        046d85af3d7a103573e56ef6861dc5d6ded9ecc7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:43:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: ensure bufffe size is at least 5

Analyzer can now see, the buffer size will have at least 5 chars
on succefull path.
---
 device_mapper/libdm-common.c | 2 +-
 libdm/libdm-common.c         | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 6a2573ec4..af2178e95 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1920,7 +1920,7 @@ static int _sysfs_find_kernel_name(uint32_t major, uint32_t minor, char *buf, si
 			continue;
 
 		if ((sz = dm_snprintf(path, sizeof(path), "%sblock/%s/dev",
-				      _sysfs_dir, name)) == -1) {
+				      _sysfs_dir, name)) < 5) {
 			log_warn("Couldn't create path for %s.", name);
 			continue;
 		}
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 708414676..56fb436bc 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1919,7 +1919,7 @@ static int _sysfs_find_kernel_name(uint32_t major, uint32_t minor, char *buf, si
 			continue;
 
 		if ((sz = dm_snprintf(path, sizeof(path), "%sblock/%s/dev",
-				      _sysfs_dir, name)) == -1) {
+				      _sysfs_dir, name)) < 5) {
 			log_warn("Couldn't create path for %s.", name);
 			continue;
 		}


