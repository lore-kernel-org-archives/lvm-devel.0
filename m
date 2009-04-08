From: Milan Broz <mbroz@redhat.com>
Date: Wed, 08 Apr 2009 17:02:24 +0200
Subject: [PATCH] Always return error when locking of VG fail.
Message-ID: <49DCBC80.2060209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Always return error when locking of VG fail.

Currently code allows quietly skip vg if locking failed
when processing PVs/LVs on cmdline.

Unfortunately there are situation when this can cause
problems - several tools uses LCK_NONBLOCK flags
(and flock can return EWOULDBLOCK) also locking can fail
for example because system is out of memory.

For example, some lvm command hold lock for vg,
another tries to remove this vg:

# vgremove vg ; echo $?
  /var/lock/lvm/V_vg: flock failed: Resource temporarily unavailable
  Can't lock volume group vg: skipping
0

This should return an error code instead.

Patch fixes it by using ECMD_FAIL if locking of VG fails.

Side effect is that some commands now return error code
when some VG is skipped. (IMHO it is correct.)

For example, installation depends on return code of these calls,
see also https://bugzilla.redhat.com/show_bug.cgi?id=492642

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/toollib.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0bc3e40..8a3065b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -285,6 +285,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			continue;	/* FIXME Unnecessary? */
 		if (!lock_vol(cmd, vgname, lock_type)) {
 			log_error("Can't lock %s: skipping", vgname);
+			ret_max = ECMD_FAILED;
 			continue;
 		}
 		if (lock_type & LCK_WRITE)
@@ -442,7 +443,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 
 	if (!lock_vol(cmd, vg_name, lock_type)) {
 		log_error("Can't lock volume group %s: skipping", vg_name);
-		return ret_max;
+		return ECMD_FAILED;
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
@@ -745,6 +746,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
 					log_error("Can't lock %s: skipping", sll->str);
+					ret_max = ECMD_FAILED;
 					continue;
 				}
 				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {



