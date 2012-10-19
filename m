From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Oct 2012 13:37:47 +0000 (UTC)
Subject: master - clvmd: fix parsing of -d argument
Message-ID: <20121019133747.9C132A1046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13fe333b54c2dedf91af2f663d6ac9bd883c3b87
Commit:        13fe333b54c2dedf91af2f663d6ac9bd883c3b87
Parent:        5f5a5d1f53d4dac462f447c0db692229f4a501b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 19 15:18:19 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 19 15:35:56 2012 +0200

clvmd: fix parsing of -d argument

clvmd -d option parsing was not working properly.

clvmd -d 2   (with space) has been ignored because of
'::' used in getopt string, and as failsafe it's been used '1'.

Later this debug_arg has been ignored and debug_opt was used
instead which happend to have value '1'.

Submitted-by: Robert Milasan <rmilasan@suse.com>
Reported-by: Robert Milasan  <rmilasan@suse.com>
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7d3995b..2c4e516 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix clvmd support for option -d and properly use its argument.
   Support use of option --yes for lvchange --persistent.
   Fix memory leak on error path for pvcreate with invalid uuid.
   Use lv_is_active() instead of lv_info() call.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ac465d9..eb0bffd 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -362,7 +362,7 @@ int main(int argc, char *argv[])
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt_long(argc, argv, "vVhfd::t:RST:CI:E:",
+	while ((opt = getopt_long(argc, argv, "vVhfd:t:RST:CI:E:",
 				  longopts, NULL)) != -1) {
 		switch (opt) {
 		case 'h':
@@ -449,7 +449,7 @@ int main(int argc, char *argv[])
 		return debug_clvmd(debug_arg, clusterwide_opt)==1?0:1;
 	}
 
-	clvmd_set_debug(debug_opt);
+	clvmd_set_debug(debug_arg);
 
 	/* Fork into the background (unless requested not to) */
 	if (!foreground_mode)


