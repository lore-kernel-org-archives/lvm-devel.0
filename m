From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:51 +0000 (UTC)
Subject: master - pvmove.c: call vg_read directly
Message-ID: <20150519190251.5488860FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=131c657735d3a315ceb9f072cb9a9591d363fa78
Commit:        131c657735d3a315ceb9f072cb9a9591d363fa78
Parent:        e5e0e220223edf0789d38a0a98341d745cf95b15
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 12:05:38 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:55:31 2015 +0200

pvmove.c: call vg_read directly

---
 tools/pvmove.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 94a5ffc..dc36955 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -629,7 +629,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	vg = poll_get_copy_vg(cmd, pv_vg_name(pv), NULL, READ_FOR_UPDATE);
+	vg = vg_read(cmd, pv_vg_name(pv), NULL, READ_FOR_UPDATE);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
@@ -719,7 +719,7 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 		return_0;
 
 	/* need read-only access */
-	vg = poll_get_copy_vg(cmd, pv_vg_name(pv), NULL, 0);
+	vg = vg_read(cmd, pv_vg_name(pv), NULL, 0);
 	if (vg_read_error(vg)) {
 		log_error("ABORTING: Can't read VG for %s.", pv_name);
 		release_vg(vg);


