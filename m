From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 21:36:46 -0400
Subject: master - lvmsar/lvmsadc: Mention dmstats when run.
Message-ID: <201703160136.v2G1akgm028681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cdaa8144ddc2d171700d2c80f18cb745828f7ed
Commit:        1cdaa8144ddc2d171700d2c80f18cb745828f7ed
Parent:        4f8651984531371f73c7bed0271c7dde8afb6c19
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 01:36:02 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 01:36:02 2017 +0000

lvmsar/lvmsadc: Mention dmstats when run.

---
 tools/stub.h |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/tools/stub.h b/tools/stub.h
index f941067..a98346a 100644
--- a/tools/stub.h
+++ b/tools/stub.h
@@ -13,22 +13,29 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+/*
 #define unimplemented \
 	log_error("Command not implemented yet."); return ECMD_FAILED
 
-/*int e2fsadm(struct cmd_context *cmd, int argc, char **argv) unimplemented*/
+int e2fsadm(struct cmd_context *cmd, int argc, char **argv) unimplemented
+*/
+
 int lvmsadc(struct cmd_context *cmd __attribute__((unused)),
 	    int argc __attribute__((unused)),
 	    char **argv __attribute__((unused)))
 {
-	unimplemented;
+	log_error("There's no 'lvmsadc' command in LVM2.");
+	log_error("Please use the superior 'dmstats' facilities instead.");
+	return ECMD_FAILED;
 }
 
 int lvmsar(struct cmd_context *cmd __attribute__((unused)),
 	   int argc __attribute__((unused)),
 	   char **argv __attribute__((unused)))
 {
-	unimplemented;
+	log_error("There's no 'lvmsar' command in LVM2.");
+	log_error("Please use the superior 'dmstats' facilities instead.");
+	return ECMD_FAILED;
 }
 
 int pvdata(struct cmd_context *cmd __attribute__((unused)),


