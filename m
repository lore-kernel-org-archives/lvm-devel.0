From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:14 +0100
Subject: [PATCH 10/29] Add some backtrace - Attention please
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <4b104b57c2aff346b77434aa52d0126801e25af9.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ATTENTION

It is a bit unclear what should happen on error path.

My idea:
 - skip to the next node if the set_name() fails.
 - print the backtrace for all error cases.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 8c0115a..147eec2 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1594,8 +1594,12 @@ static int _process_mapper_dir(struct dm_task *dmt)
 		    !strcmp(dirent->d_name, "..") ||
 		    !strcmp(dirent->d_name, "control"))
 			continue;
-		dm_task_set_name(dmt, dirent->d_name);
-		dm_task_run(dmt);
+		if (!dm_task_set_name(dmt, dirent->d_name)) {
+			stack;
+			continue; /* try next name */
+		}
+		if (!dm_task_run(dmt))
+                        stack;  /* keep going */
 	}
 
 	if (closedir(d))
-- 
1.7.3.2


