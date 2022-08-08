From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Mon,  8 Aug 2022 13:47:54 +0000 (GMT)
Subject: master - shell: also output error message about max number of args hit with JSON format
Message-ID: <20220808134754.03EEE3858400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fa99164938d11221fe6afc30af4f016bbc02450
Commit:        2fa99164938d11221fe6afc30af4f016bbc02450
Parent:        99ce09ae778c2cc4aa2611e425bba5287b8b9513
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 15:15:32 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 8 15:46:52 2022 +0200

shell: also output error message about max number of args hit with JSON format

If using JSON format for lvm shell's output, the error message about
exceeding the maximum number of arguments was not reported on output if
this condition was ever hit.

This is because the JSON format (as well as any other future format)
requires extra formatting compared to "basic" format and so it also
requires extra calls when it comes to reporting. The report needs to
be added to a report group and then popped and put on output with
specialized "dm_report_group_output_and_pop_all".

This "output and pop" is normally executed after we execute the command
in the lvm shell. When we didn't get to the command exection at all because
some precondition was not met (like hitting the limit for the number of
arguments for the command here), we skipped this important call and
so there was no log report output.

Right now, it's only this exact error message for which we need to call
"output and pop" directly, all the other error messages are about
initializing and setting the log report itself which we can't report
obviously.

Before this patch:

  lvm> pvs 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65
  lvm>

With this patch applied:

  lvm> pvs 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65
  {
      "log": [
          {"log_seq_num":"1", "log_type":"error", "log_context":"shell", "log_object_type":"cmd", "log_object_name":"", "log_object_id":"", "log_object_group":"", "log_object_group_id":"", "log_message":"Too many arguments, sorry.", "log_errno":"-1", "log_ret_code":"0"}
      ]
  }

If there's any other error message in the future before we execute the
command itself, we also need to call the "output and pop" directly.
---
 tools/lvm.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tools/lvm.c b/tools/lvm.c
index e80113e0d..756328f3f 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -234,6 +234,16 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_CMD);
 
 	while (1) {
+		/*
+		 * Note: If we need to output the log report before we get to the dm_report_group_output_and_pop_all
+		 * at the end of this loop, like hitting a failure situation before we execute the command itself,
+		 * don't forget to directly call dm_report_group_output_and_pop_all, otherwise no log meesage will
+		 * appear on output (for output formats other than 'basic').
+		 *
+		 * Obviously, you can't output the 'log report' if the error is in initializing or setting
+		 * the report itself. In this case, we can only return an error code, but no message.
+		 */
+
 		report_reset_cmdlog_seqnum();
 		if (cmd->cmd_report.log_rh) {
 			/*
@@ -275,6 +285,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
 			_discard_log_report_content(cmd);
 			log_error("Too many arguments, sorry.");
+			dm_report_group_output_and_pop_all(cmd->cmd_report.report_group);
 			continue;
 		}
 

