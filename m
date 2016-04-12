From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Apr 2016 11:10:35 +0000 (UTC)
Subject: master - cleanup: avoid declaring var in the middle of code
Message-ID: <20160412111036.0147861BCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f7975cb351158d3b2245b4262761a698c6c5d7b
Commit:        0f7975cb351158d3b2245b4262761a698c6c5d7b
Parent:        147c9c01a21687b82314a62571cfc390a9a606a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 12 11:46:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 12 11:47:51 2016 +0200

cleanup: avoid declaring var in the middle of code

Easier to read code.
---
 lib/device/dev-cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 6abb6a7..b5f2152 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -904,11 +904,11 @@ int dev_cache_index_devs(void)
 	} else if (!sysfs_has_dev_block)
 		return 1;
 
-	int with_udev = obtain_device_list_from_udev() &&
-			udev_get_library_context();
+	if (obtain_device_list_from_udev() &&
+	    udev_get_library_context())
+		return _dev_cache_iterate_devs_for_index();  /* with udev */
 
-	return with_udev ? _dev_cache_iterate_devs_for_index()
-			 : _dev_cache_iterate_sysfs_for_index(path);
+	return _dev_cache_iterate_sysfs_for_index(path);
 }
 
 #ifdef UDEV_SYNC_SUPPORT


