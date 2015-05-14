From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 May 2015 14:49:55 +0000 (UTC)
Subject: master - config: description can refer to etc location
Message-ID: <20150514144955.C046C601E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8081ee1440d4a88247504c8f985161098637c520
Commit:        8081ee1440d4a88247504c8f985161098637c520
Parent:        cf93fe39e33a3550725a06272f6008b02281918f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 14 09:47:42 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 14 09:47:42 2015 -0500

config: description can refer to etc location

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a7cb5d0..4e3823e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -905,7 +905,7 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"System IDs beginning localhost are not permitted.\n"
 	"machineid - Use the contents of the machine-id file to set the\n"
 	"system ID.  Some systems create this file at installation time.\n"
-	"See 'man machine-id'.\n"
+	"See 'man machine-id' and global/etc.\n"
 	"file - Use the contents of another file (system_id_file) to set\n"
 	"the system ID.\n")
 


