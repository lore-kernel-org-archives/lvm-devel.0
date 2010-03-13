From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 12 Mar 2010 16:17:17 -0800
Subject: [PATCH] Use correct array size!
Message-ID: <8db1b9ee17a8c097a7b3.1268439437@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r 5d08ba4ae8e8 -r 8db1b9ee17a8 daemons/dmeventd/dmeventd.c
--- a/daemons/dmeventd/dmeventd.c	Thu Mar 11 16:05:21 2010 -0800
+++ b/daemons/dmeventd/dmeventd.c	Fri Mar 12 16:15:25 2010 -0800
@@ -1369,7 +1369,7 @@ static int _handle_request(struct dm_eve
 		{ DM_EVENT_CMD_ACTIVE, _active},
 	}, *req;
 
-	for (req = requests; req < requests + sizeof(requests); req++)
+	for (req = requests; req < requests + sizeof(requests) / sizeof(requests[0]); req++)
 		if (req->cmd == msg->cmd)
 			return req->f(message_data);
 


