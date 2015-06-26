From: Lidong Zhong <lzhong@suse.com>
Date: Fri, 26 Jun 2015 17:16:06 +0800
Subject: [PATCH] dmeventd: fix dso name wrong compare
Message-ID: <1435310166-2418-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the dso name is not set in client, then it will be replaced by "-".
So the server should compare the dso name with "-" to decide whether
it is set.
---
 daemons/dmeventd/dmeventd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index fcfa423..d81c4ee 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1190,12 +1190,12 @@ static int _want_registered_device(char *dso_name, char *device_uuid,
 				   struct thread_status *thread)
 {
 	/* If DSO names and device paths are equal. */
-	if (dso_name && device_uuid)
+	if (strcmp(dso_name,"-") && device_uuid)
 		return !strcmp(dso_name, thread->dso_data->dso_name) &&
 		    !strcmp(device_uuid, thread->device.uuid);
 
 	/* If DSO names are equal. */
-	if (dso_name)
+	if (strcmp(dso_name, "-"))
 		return !strcmp(dso_name, thread->dso_data->dso_name);
 
 	/* If device paths are equal. */
-- 
1.8.1.4


