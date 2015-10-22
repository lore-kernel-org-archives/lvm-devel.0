From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:47 +0000 (UTC)
Subject: master - dmeventd: use dm_hold_control_dev
Message-ID: <20151022213347.D037160B67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02eb000f5145aa60578b4591053bff9a797e64cc
Commit:        02eb000f5145aa60578b4591053bff9a797e64cc
Parent:        efc76ca33dec99e3b0499ef28fb9236815ad2258
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 21 20:52:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:34:27 2015 +0200

dmeventd: use dm_hold_control_dev

Need here to keep  control device opened while there is 'any' dso
plugin loaded - otherwise there would a race closing controlfd
inside lvm2 plugin while some other monitoring thread would
tried to execute another WAITEVENT task.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2b87e4b..000bddd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Dmeventd closes control device when no device is monitored.
   Thin plugin for dmeventd improved percentage usage.
   Snapshot plugin for dmeventd improved percentage usage.
   Add dm_hold_control_dev to allow holding of control device open.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 69fe393..885aa9d 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -282,6 +282,13 @@ static void _lib_put(struct dso_data *data)
 		dlclose(data->dso_handle);
 		UNLINK_DSO(data);
 		_free_dso_data(data);
+
+		/* Close control device if there is no plugin in-use */
+		if (dm_list_empty(&_dso_registry)) {
+			DEBUGLOG("Unholding control device.");
+			dm_hold_control_dev(0);
+			dm_lib_release();
+		}
 	}
 }
 
@@ -344,6 +351,12 @@ static struct dso_data *_load_dso(struct message_data *data)
 		goto_bad;
 	}
 
+	/* Keep control device open until last user closes */
+	if (dm_list_empty(&_dso_registry)) {
+		DEBUGLOG("Holding control device open.");
+		dm_hold_control_dev(1);
+	}
+
 	/*
 	 * Keep handle to close the library once
 	 * we've got no references to it any more.


