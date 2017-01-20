From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:03 +0000 (UTC)
Subject: master - dmeventd_thin: handling of internal command
Message-ID: <20170120230403.836D760D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eca964b554e371f699758ebfa0837f2e7a8cba87
Commit:        eca964b554e371f699758ebfa0837f2e7a8cba87
Parent:        d80f9a107fc869d541a36c8c9d12c32589c34c12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 09:56:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: handling of internal command

---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 0cca98f..930f9fc 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -121,6 +121,7 @@ int dmeventd_lvm2_run(const char *cmdline)
 int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 			  const char *cmd, const char *device)
 {
+	static char _internal_prefix[] =  "_dmeventd_";
 	char *vg = NULL, *lv = NULL, *layer;
 	int r;
 
@@ -135,6 +136,21 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 	    (layer = strstr(lv, "_mlog")))
 		*layer = '\0';
 
+	if (!strncmp(cmd, _internal_prefix, sizeof(_internal_prefix) - 1)) {
+		dmeventd_lvm2_lock();
+		/* output of internal command passed via env var */
+		if (!dmeventd_lvm2_run(cmd))
+			cmd = NULL;
+		else if ((cmd = getenv(cmd)))
+			cmd = dm_pool_strdup(mem, cmd); /* copy with lock */
+		dmeventd_lvm2_unlock();
+
+		if (!cmd) {
+			log_error("Unable to find configured command.");
+			return 0;
+		}
+	}
+
 	r = dm_snprintf(buffer, size, "%s %s/%s", cmd, vg, lv);
 
 	dm_pool_free(mem, vg);


