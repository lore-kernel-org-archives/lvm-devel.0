From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:56 +0200
Subject: [PATCH 10/14] Fix void* arithmetic - use char*
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <6b0e78312b13e0f0b84176fdc5e57d195c11f6e5.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index d2579ad..bbe1de4 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1104,7 +1104,7 @@ struct dm_deps *dm_task_get_deps(struct dm_task *dmt)
 		return _dm_task_get_deps_v1(dmt);
 #endif
 
-	return (struct dm_deps *) (((void *) dmt->dmi.v4) +
+	return (struct dm_deps *) (((char *) dmt->dmi.v4) +
 				   dmt->dmi.v4->data_start);
 }
 
@@ -1115,13 +1115,13 @@ struct dm_names *dm_task_get_names(struct dm_task *dmt)
 		return _dm_task_get_names_v1(dmt);
 #endif
 
-	return (struct dm_names *) (((void *) dmt->dmi.v4) +
+	return (struct dm_names *) (((char *) dmt->dmi.v4) +
 				    dmt->dmi.v4->data_start);
 }
 
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt)
 {
-	return (struct dm_versions *) (((void *) dmt->dmi.v4) +
+	return (struct dm_versions *) (((char *) dmt->dmi.v4) +
 				       dmt->dmi.v4->data_start);
 }
 
-- 
1.7.2


