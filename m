From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 12 Mar 2013 12:05:25 +0000 (UTC)
Subject: master - dmsetup: fix 'splitname -o' to not fail if used without '-c'
Message-ID: <20130312120525.E6F7659D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=521a0a3323507e1d07568d3047283975e66ca193
Commit:        521a0a3323507e1d07568d3047283975e66ca193
Parent:        cbfb5a98b5dbe699aaafbced00120f60aaa35231
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 12 12:37:24 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 12 13:01:57 2013 +0100

dmsetup: fix 'splitname -o' to not fail if used without '-c'

This was a regression introduced with e33fd978a8a56228677c14612fce99b3b3588125
(libdm v1.02.68/lvm2 v2.02.89) with the introduction of new output
fields blkdevname and blkdevs_used for ls and deps dmsetup commands.

A new common '_process_options' fn was added with that commit, but the
fn was called prematurely which then broke processing of
'dmsetup splitname -o' which should implicitly use '-c' option
and this was failing after the commit:

  alatyr/~ $ dmsetup splitname -o lv_name /dev/mapper/vg_data-test
  Option not recognised: lv_name
  Couldn't process command line.

The '-c' had to be used for correct operation:

  alatyr/~ $ dmsetup splitname -c -o lv_name /dev/mapper/vg_data-test
  LV
  test

Now fixed to work as it did before:

  alatyr/~ $ dmsetup splitname -o lv_name /dev/mapper/vg_data-test
  LV
  test
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3bf8927..98ffa6f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Fix 'dmsetup splitname -o' to not fail if used without '-c' switch (1.02.68).
   Add dm_config_write_{node_out/one_node_out} for enhanced config output.
   Add dm_config_value_is_bool to check for boolean value in supported formats.
   Fix config node lookup inside empty sections to not return the section itself.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8b1145f..ce46d6c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3749,9 +3749,6 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		return 0;
 	}
 
-	if (!_process_options(_string_args[OPTIONS_ARG]))
-		return 0;
-
 	if (_switches[TABLE_ARG] && _switches[NOTABLE_ARG]) {
 		fprintf(stderr, "--table and --notable are incompatible.\n");
 		return 0;
@@ -3824,6 +3821,11 @@ int main(int argc, char **argv)
 	if (!strcmp(cmd->name, "mangle"))
 		dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
+	if (!_process_options(_string_args[OPTIONS_ARG])) {
+		fprintf(stderr, "Couldn't process command line.\n");
+		goto out;
+	}
+
 	if (_switches[COLS_ARG]) {
 		if (!_report_init(cmd))
 			goto out;


