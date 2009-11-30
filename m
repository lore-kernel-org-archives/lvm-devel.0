From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 30 Nov 2009 14:56:22 -0500
Subject: [PATCH] lvm2: sync error handling on secondary mirror in dmeventd
Message-ID: <4B142366.7050506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set the ME_FAILURE flag if the error is related to sync on the secondary
mirror. A sync error on the secondary mirror occurs by a write I/O and
the error can be treated as the regular write error on mirror legs.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: LVM2.02.57-20091125/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.57-20091125.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.57-20091125/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -68,10 +68,12 @@ static int _process_status_code(const ch
 		syslog(LOG_ERR, "%s device %s flush failed.\n",
 		       dev_type, dev_name);
 		r = ME_FAILURE;
-	} else if (status_code == 'S')
+	} else if (status_code == 'S') {
 		syslog(LOG_ERR, "%s device %s sync failed.\n",
 		       dev_type, dev_name);
-	else if (status_code == 'R')
+		if (!strcmp(dev_type, "Secondary mirror"))
+			r = ME_FAILURE;
+	} else if (status_code == 'R')
 		syslog(LOG_ERR, "%s device %s read failed.\n",
 		       dev_type, dev_name);
 	else if (status_code != 'A') {


