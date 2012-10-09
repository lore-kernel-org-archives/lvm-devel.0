From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:50 +0000 (UTC)
Subject: master - libdaemon-server: Optimize logging for a fast no-output path.
Message-ID: <20121009055250.4E1FD2473@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b4c2833d984f6b6a8dde394168b4653cdd47863
Commit:        4b4c2833d984f6b6a8dde394168b4653cdd47863
Parent:        cc9c02fe68f6ee8f5f6bcf885c1ed41387778bb7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 18:34:33 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

libdaemon-server: Optimize logging for a fast no-output path.

---
 libdaemon/server/daemon-log.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 837fffd..b31bb4e 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -52,6 +52,16 @@ void daemon_log(log_state *s, int type, const char *message) {
 	}
 }
 
+static int _type_interesting(log_state *s, int type) {
+	int i = 0;
+	while ( backend[i].id ) {
+		if ( (s->log_config[type] & backend[i].id) == backend[i].id )
+			return 1;
+		++ i;
+	}
+	return 0;
+}
+
 void daemon_logf(log_state *s, int type, const char *fmt, ...) {
 	char *buf;
 	va_list ap;
@@ -78,12 +88,18 @@ static int _log_line(const char *line, void *baton) {
 
 void daemon_log_cft(log_state *s, int type, const char *prefix, const struct dm_config_node *n)
 {
+	if (!_type_interesting(s, type))
+		return;
+
 	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
 	dm_config_write_node(n, &_log_line, &b);
 }
 
 void daemon_log_multi(log_state *s, int type, const char *prefix, const char *msg)
 {
+	if (!_type_interesting(s, type))
+		return;
+
 	struct log_line_baton b = { .s = s, .type = type, .prefix = prefix };
 	char *buf = dm_strdup(msg);
 	char *pos = buf;


