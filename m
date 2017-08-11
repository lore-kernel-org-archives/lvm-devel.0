From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 11 Aug 2017 15:51:05 -0400
Subject: master - pvcreate: Use maximum metadata area size with --restorefile
Message-ID: <201708111951.v7BJp5fm001149@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=42fa20d0d0136c1aeb3ccdf0654c64beeee05821
Commit:        42fa20d0d0136c1aeb3ccdf0654c64beeee05821
Parent:        4fa5add6b1bd4d7f7313f2950021a09e4130ad08
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 11 20:41:37 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 11 20:41:37 2017 +0100

pvcreate: Use maximum metadata area size with --restorefile

If the PV was originally created with a larger-than-default
metadata area the restored one wasn't and might not even be
large enough to hold the metadata!
---
 WHATS_NEW        |    1 +
 tools/pvcreate.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e05fae2..2e1294e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Use maximum metadataarea size that fits with pvcreate --restorefile.
   Always clear cached bootloaderarea when wiping label e.g. in pvcreate.
   Disallow --bootloaderareasize with pvcreate --restorefile.
   Fix lvmlockd check for running lock managers during lock adoption.
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 0fe5ad5..9dc50e4 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -135,6 +135,15 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!pvcreate_params_from_args(cmd, &pp))
 		return EINVALID_CMD_LINE;
 
+	/*
+	 * If --metadatasize was not given with --restorefile, set it to pe_start.
+	 * Later code treats this as a maximum size and reduces it to fit.
+	 */
+	if (!arg_is_set(cmd, metadatasize_ARG) && arg_is_set(cmd, restorefile_ARG))
+		pp.pva.pvmetadatasize = pp.pva.pe_start;
+
+	/* FIXME Also needs to check any 2nd metadata area isn't inside the data area! */
+
 	pp.pv_count = argc;
 	pp.pv_names = argv;
 


