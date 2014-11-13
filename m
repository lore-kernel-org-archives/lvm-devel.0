From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 13 Nov 2014 12:27:15 +0000 (UTC)
Subject: master - pvck: Use non-zero exit status after failure.
Message-ID: <20141113122715.8CA5C60F17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efe5245e47201e1947ce0bf60990a7de2151e296
Commit:        efe5245e47201e1947ce0bf60990a7de2151e296
Parent:        c3e29903590b596bfead1d84f91a32362d8e640f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Nov 13 12:26:43 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Nov 13 12:26:43 2014 +0000

pvck: Use non-zero exit status after failure.

---
 WHATS_NEW    |    1 +
 tools/pvck.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9859939..19f029b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Exit with non-zero status code when pvck encounters a problem.
   Fix clean_tree after activation/resume for cache target (2.02.112).
 
 Version 2.02.112 - 11th November 2014
diff --git a/tools/pvck.c b/tools/pvck.c
index e45e77a..0b868e8 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -18,9 +18,11 @@
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i;
+	int ret_max = ECMD_PROCESSED;
 
 	/* FIXME: validate cmdline options */
 	/* FIXME: what does the cmdline look like? */
+
 	/*
 	 * Use what's on the cmdline directly, and avoid calling into
 	 * some of the other infrastructure functions, so as to avoid
@@ -32,10 +34,12 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		log_verbose("Scanning %s", argv[i]);
 
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		pv_analyze(cmd, argv[i],
-			   arg_uint64_value(cmd, labelsector_ARG,
-					   UINT64_C(0)));
+		if (!pv_analyze(cmd, argv[i],
+				arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0)))) {
+			stack;
+			ret_max = ECMD_FAILED;
+		}
 	}
 
-	return ECMD_PROCESSED;
+	return ret_max;
 }


