From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:18 +0000 (UTC)
Subject: master - lvmpolld-client.c: be more specific about fallback on error
Message-ID: <20150512152218.9D60E60403@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24a92e08c0d9b7b9a5333c4413f6e95900f966f8
Commit:        24a92e08c0d9b7b9a5333c4413f6e95900f966f8
Parent:        c3d351ec9b4d98a08b4d5556130870332f650b67
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 15:34:45 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:43 2015 +0200

lvmpolld-client.c: be more specific about fallback on error

if client fails to contact lvmpolld it fallbacks to using classical
polldaemon. Be more specific and give some hints to users what went
possibly wrong
---
 lib/lvmpolld/lvmpolld-client.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index ee8860f..d03a650 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -34,7 +34,7 @@ static const char* _lvmpolld_socket;
 
 static daemon_handle _lvmpolld = { .error = 0 };
 
-static daemon_handle _lvmpolld_connect(const char *socket)
+static daemon_handle _lvmpolld_open(const char *socket)
 {
 	daemon_info lvmpolld_info = {
 		.path = "lvmpolld",
@@ -56,15 +56,26 @@ void lvmpolld_set_socket(const char *socket)
 	_lvmpolld_socket = socket;
 }
 
+static void _lvmpolld_connect_or_warn(void)
+{
+	if (!_lvmpolld_connected && !_lvmpolld.error) {
+		_lvmpolld = _lvmpolld_open(_lvmpolld_socket);
+		if ( _lvmpolld.socket_fd >= 0 && !_lvmpolld.error) {
+			log_debug_lvmpolld("Sucessfully connected to lvmpolld on fd %d.", _lvmpolld.socket_fd);
+			_lvmpolld_connected = 1;
+		} else {
+			log_warn("WARNING: Failed to connect to lvmpolld. Proceeding with polling without using lvmpolld.");
+			log_warn("WARNING: Check global/use_lvmpolld in lvm.conf or the lvmpolld daemon state.");
+		}
+	}
+}
+
 int lvmpolld_use(void)
 {
-	if (!_lvmpolld_use)
+	if (!_lvmpolld_use || !_lvmpolld_socket)
 		return 0;
 
-	if (!_lvmpolld_connected && !_lvmpolld.error) {
-		_lvmpolld = _lvmpolld_connect(_lvmpolld_socket);
-		_lvmpolld_connected = _lvmpolld.socket_fd >= 0;
-	}
+	_lvmpolld_connect_or_warn();
 
 	return _lvmpolld_connected;
 }


