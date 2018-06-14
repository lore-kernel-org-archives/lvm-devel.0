From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:25 -0400
Subject: master - debug: missing trace
Message-ID: <201806142003.w5EK3POS004094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4abbafde7ac1918ecb54c23ec90d2d9dcdc9c02
Commit:        f4abbafde7ac1918ecb54c23ec90d2d9dcdc9c02
Parent:        b58160a1913fdd61c378479f6362bd904e7de942
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 13 15:56:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

debug: missing trace

---
 tools/toollib.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 7caab45..f64bd58 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1963,6 +1963,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		log_very_verbose("Processing VG %s %s", vg_name, uuid);
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
+			stack;
 			ret_max = ECMD_FAILED;
 			report_log_ret_code(ret_max);
 			continue;


