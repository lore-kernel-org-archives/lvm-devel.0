From: okozina <okozina@fedoraproject.org>
Date: Mon,  8 Jun 2015 14:02:01 +0000 (UTC)
Subject: master - lvmetad.c: internal err on modifying global handle with open connection
Message-ID: <20150608140201.3241861137@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c312932215f8d70c4f6beb7db506898f4670cfe
Commit:        7c312932215f8d70c4f6beb7db506898f4670cfe
Parent:        b89ad7e2d4a5dd5e1947c2b14941f6a87d354451
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 22 14:55:42 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Jun 8 16:01:40 2015 +0200

lvmetad.c: internal err on modifying global handle with open connection

lvmetad_init() should not be called with open connection to the daemon.
Doing so is considered to be an internall error within lvm2 code.

Such coincidence can't occur within current code. Let's assure us it won't
ever happen.
---
 lib/cache/lvmetad.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 73a382c..dd1219b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -46,6 +46,10 @@ void lvmetad_init(struct cmd_context *cmd)
 	if (!_lvmetad_use && !access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK))
 		log_warn("WARNING: lvmetad is running but disabled."
 			 " Restart lvmetad before enabling it!");
+
+	if (_lvmetad_connected)
+		log_debug(INTERNAL_ERROR "Refreshing lvmetad global handle while connection with the daemon is active");
+
 	_lvmetad_cmd = cmd;
 }
 


