From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:30 +0000 (UTC)
Subject: master - libdm: always dm_lib_init mangling mode
Message-ID: <20140408090230.3679560CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0003d3be5b002aa27de978ad95fb2b310ca6529
Commit:        f0003d3be5b002aa27de978ad95fb2b310ca6529
Parent:        bd2500e62ea66984d4c3669a4429afa459165178
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:24:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:12 2014 +0200

libdm: always dm_lib_init mangling mode

If there ever would be a second call to dm_lib_init()
and envvar would be improperly set, some last set value
would be used while it should reset to default mangling mode.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    7 +++----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d6bebb1..6545127 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Always reinitialize _name_mangling_mode in dm_lib_init().
   Add tracking flag about implicitly added devices into dm_tree.
   Stop timeout thread immediately when the last worker thread is finished.
   Fix dmeventd logging with parallel wait event processing.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 72fa508..9d8836c 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -91,16 +91,15 @@ void dm_lib_init(void)
 	if (getenv("DM_DISABLE_UDEV"))
 		_udev_disabled = 1;
 
-	env = getenv(DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME);
-	if (env && *env) {
+	_name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
+	if ((env = getenv(DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME))) {
 		if (!strcasecmp(env, "none"))
 			_name_mangling_mode = DM_STRING_MANGLING_NONE;
 		else if (!strcasecmp(env, "auto"))
 			_name_mangling_mode = DM_STRING_MANGLING_AUTO;
 		else if (!strcasecmp(env, "hex"))
 			_name_mangling_mode = DM_STRING_MANGLING_HEX;
-	} else
-		_name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
+	}
 }
 
 /*


