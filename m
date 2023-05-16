From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 16 May 2023 15:23:46 +0000 (GMT)
Subject: main - toollib: provide proper hint for referencing VG uuid in case of duplicate VG names
Message-ID: <20230516152346.470A23858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b4e7d1625ddc48dd9393f03a59cc6b74113275a
Commit:        3b4e7d1625ddc48dd9393f03a59cc6b74113275a
Parent:        fd6e113bba5fed5ee41152cde33220294c24ce2b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 16 17:17:55 2023 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 16 17:17:55 2023 +0200

toollib: provide proper hint for referencing VG uuid in case of duplicate VG names

vgrename does not support -S|--select, so do not provide a hint about
using it. Instead, provide a hint about using VG uuid directly.

???  vgs
  WARNING: VG name vg1 is used by VGs DXjcSK-gWfu-5gLh-9Kbg-sG49-dtRr-GqXzGL and MVMfyM-sjOa-M2xV-AT4Y-JddR-h4SP-UO5Ttk.
  Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
  VG     #PV #LV #SN Attr   VSize   VFree
  vg1      1   0   0 wz--n- 124.00m 124.00m
  vg1      1   0   0 wz--n- 124.00m 124.00m

(vgrename does not support -S|--select)
???  vgrename vg1 vg2
  WARNING: VG name vg1 is used by VGs DXjcSK-gWfu-5gLh-9Kbg-sG49-dtRr-GqXzGL and MVMfyM-sjOa-M2xV-AT4Y-JddR-h4SP-UO5Ttk.
  Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
  Multiple VGs found with the same name: skipping vg1
  Use VG uuid in place of the VG name.

(vgchange does support -S|--select)
???  vgchange --addtag a vg1
  WARNING: VG name vg1 is used by VGs DXjcSK-gWfu-5gLh-9Kbg-sG49-dtRr-GqXzGL and MVMfyM-sjOa-M2xV-AT4Y-JddR-h4SP-UO5Ttk.
  Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
  Multiple VGs found with the same name: skipping vg1
  Use --select vg_uuid=<uuid> in place of the VG name.
---
 tools/lvmcmdline.c | 12 ++++++++++++
 tools/toollib.c    |  7 ++++++-
 tools/tools.h      |  1 +
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a5bb6a5c5..6bbf1af26 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -179,6 +179,18 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 
 
 /* Command line args */
+int arg_is_valid_for_command(const struct cmd_context *cmd, int a)
+{
+	int i;
+
+	for (i = 0; i < cmd->cname->num_args; i++) {
+		if (cmd->cname->valid_args[i] == a)
+			return 1;
+	}
+
+	return 0;
+}
+
 unsigned arg_count(const struct cmd_context *cmd, int a)
 {
 	return cmd->opt_arg_values ? cmd->opt_arg_values[a].count : 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 6b590189b..2f4756b6b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2313,7 +2313,12 @@ static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
 		 * is unknown.
 		 */
 		log_error("Multiple VGs found with the same name: skipping %s", sl->str);
-		log_error("Use --select vg_uuid=<uuid> in place of the VG name.");
+
+		if (arg_is_valid_for_command(cmd, select_ARG))
+			log_error("Use --select vg_uuid=<uuid> in place of the VG name.");
+		else
+			log_error("Use VG uuid in place of the VG name.");
+
 		dm_list_del(&sl->list);
 		ret = ECMD_FAILED;
 	}
diff --git a/tools/tools.h b/tools/tools.h
index 36da3bc7e..60952a2aa 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -193,6 +193,7 @@ int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 int dumptype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
+int arg_is_valid_for_command(const struct cmd_context *cmd, int a);
 unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
 int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, ...);

