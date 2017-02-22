From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Feb 2017 21:42:57 +0000 (UTC)
Subject: master - man: improve writemostly PV arg
Message-ID: <20170222214257.C2E2660C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1eb1869626cbdacbeca037fbd81d01756f2faa76
Commit:        1eb1869626cbdacbeca037fbd81d01756f2faa76
Parent:        aa72caca5a19c67caffefc3f967af630b93ee2f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 22 15:20:44 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 22 15:20:44 2017 -0600

man: improve writemostly PV arg

---
 tools/command.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0d40af6..d170eec 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1785,16 +1785,6 @@ static void print_val_man(const char *str)
 	int line_argc;
 	int i;
 
-	if (!strcmp(str, "Number") ||
-	    !strcmp(str, "String") ||
-	    !strncmp(str, "VG", 2) ||
-	    !strncmp(str, "LV", 2) ||
-	    !strncmp(str, "PV", 2) ||
-	    !strcmp(str, "Tag")) {
-		printf("\\fI%s\\fP", str);
-		return;
-	}
-
 	/*
 	 * The suffix [k|unit] is just printed in plain text.
 	 * Doing bold k and underlined unit creates a lot of
@@ -1823,6 +1813,11 @@ static void print_val_man(const char *str)
 		return;
 	}
 
+	if (!strcmp(str, "PV[:t|n|y]")) {
+		printf("\\fIPV\\fP[\\fB:t\\fP|\\fBn\\fP|\\fBy\\fP]");
+		return;
+	}
+
 	/*
 	 * I think this bit is almost unnecessary with the specific
 	 * ones checked above.
@@ -1841,6 +1836,16 @@ static void print_val_man(const char *str)
 		return;
 	}
 
+	if (!strcmp(str, "Number") ||
+	    !strcmp(str, "String") ||
+	    !strncmp(str, "VG", 2) ||
+	    !strncmp(str, "LV", 2) ||
+	    !strncmp(str, "PV", 2) ||
+	    !strcmp(str, "Tag")) {
+		printf("\\fI%s\\fP", str);
+		return;
+	}
+
 	if (strchr(str, '|')) {
 		int len = strlen(str);
 		line = dm_strdup(str);


