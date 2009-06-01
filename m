From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 1 Jun 2009 12:04:17 -0400 (EDT)
Subject: [PATCH] DM: change __kernel_dev_t to uint32_t
Message-ID: <Pine.LNX.4.64.0906011158030.16282@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change __kernel_dev_t to uint32_t

In current 2.6 kernels, this is defined only inside kernel, there is no way
how ti could me made available to the applications (if you attempt to make
it available with #defines, you get many symbol conflicts with libc).

So define it as uint32_t. This interface is legacy anyway and can't be used
in current kernels.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/ioctl/libdm-compat.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.2.02.47/libdm/ioctl/libdm-compat.h
===================================================================
--- LVM2.2.02.47.orig/libdm/ioctl/libdm-compat.h	2009-05-26 15:19:00.000000000 +0200
+++ LVM2.2.02.47/libdm/ioctl/libdm-compat.h	2009-05-26 15:24:34.000000000 +0200
@@ -40,7 +40,7 @@ struct dm_ioctl_v1 {
 	int32_t open_count;	/* out */
 	uint32_t flags;		/* in/out */
 
-	__kernel_dev_t dev;	/* in/out */
+	uint32_t dev;		/* in/out */
 
 	char name[DM_NAME_LEN];	/* device name */
 	char uuid[DM_UUID_LEN];	/* unique identifier for
@@ -60,7 +60,7 @@ struct dm_target_spec_v1 {
 struct dm_target_deps_v1 {
 	uint32_t count;
 
-	__kernel_dev_t dev[0];	/* out */
+	uint32_t dev[0];	/* out */
 };
 
 enum {


