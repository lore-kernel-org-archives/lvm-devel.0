From: Milan Broz <mbroz@redhat.com>
Date: Fri, 05 Jun 2009 15:38:41 +0200
Subject: [PATCH] Do not fork daemon when dmeventd cannot be found.
Message-ID: <4A291FE1.6010006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not fork daemon when dmeventd cannot be found.

Otherwise it prints many errors about leaked pools.

(More elegant is properly release context, but this 
workaround is sufficient IMHO.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/dmeventd/libdevmapper-event.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 2650cf0..dae76d3 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -425,6 +425,12 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 
       start_server:
 	/* server is not running */
+
+	if (stat(DMEVENTD_PATH, &statbuf)) {
+		log_error("Unable to find dmeventd.");
+		return_0;
+	}
+
 	pid = fork();
 
 	if (pid < 0)



