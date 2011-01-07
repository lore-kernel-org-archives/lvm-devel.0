From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:33 +0100
Subject: [PATCH 5/8] Define DM_COOKIE_AUTO_CREATE
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <1423d759bc7362acf344c234beb6c75d84fecfbb.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

TODO: Use it also for already written code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 994a364..eea1a6c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1214,6 +1214,11 @@ void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
 void dm_udev_set_checking(int checking);
 int dm_udev_get_checking(void);
+
+/*
+ * Default value to get new auto generated cookie created
+ */
+#define DM_COOKIE_AUTO_CREATE 0
 int dm_udev_create_cookie(uint32_t *cookie);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
-- 
1.7.3.4


