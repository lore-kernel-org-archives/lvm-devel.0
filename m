From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:16:51 +0000 (UTC)
Subject: master - libdm: internal is_selinux_enabled wrapper
Message-ID: <20140224201651.2F51B612CA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8346f106b448caeb9625d05eb9d196cced860288
Commit:        8346f106b448caeb9625d05eb9d196cced860288
Parent:        ee89ac7b887bc227f9c4d436c0acaa61c7ee4deb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 20 17:09:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 20:58:41 2014 +0100

libdm: internal is_selinux_enabled wrapper

There is no point to call this external function more then once.
(As suggested by selinux developer)
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   19 +++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3d7c734..a0b8066 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Wrap is_selinux_enabled() to be called just once.
   Use correctly signed 64b constant when working with raid volumes.
   Exit dmeventd with pidfile cleanup instead of raising SIGKILL on DIE request.
   Add new DM_EVENT_GET_PARAMETERS request to dmeventd protocol.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 5ec5769..2ec66e7 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -868,12 +868,27 @@ static int _selabel_lookup(const char *path, mode_t mode,
 }
 #endif
 
+#ifdef HAVE_SELINUX
+static int _is_selinux_enabled(void)
+{
+	static int _tested = 0;
+	static int _enabled;
+
+	if (!_tested) {
+		_tested = 1;
+		_enabled = is_selinux_enabled();
+	}
+
+	return _enabled;
+}
+#endif
+
 int dm_prepare_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
 	security_context_t scontext = NULL;
 
-	if (is_selinux_enabled() <= 0)
+	if (_is_selinux_enabled() <= 0)
 		return 1;
 
 	if (path) {
@@ -901,7 +916,7 @@ int dm_set_selinux_context(const char *path, mode_t mode)
 #ifdef HAVE_SELINUX
 	security_context_t scontext = NULL;
 
-	if (is_selinux_enabled() <= 0)
+	if (_is_selinux_enabled() <= 0)
 		return 1;
 
 	if (!_selabel_lookup(path, mode, &scontext))


