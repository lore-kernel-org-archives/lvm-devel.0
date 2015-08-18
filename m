From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 18 Aug 2015 21:51:05 +0000 (UTC)
Subject: master - lvmlockctl: fix debug output
Message-ID: <20150818215105.7CE0561009@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c5a85ce249f6a076ac1623ad6ad8f29bdbbb199
Commit:        9c5a85ce249f6a076ac1623ad6ad8f29bdbbb199
Parent:        c09dad71fb56710caa375404ef9974d72079422e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 18 16:49:33 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 18 16:49:33 2015 -0500

lvmlockctl: fix debug output

---
 daemons/lvmlockd/lvmlockctl.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 148077e..e2ad9c5 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -151,13 +151,12 @@ static void format_info_r(char *line, char *r_name_out, char *r_type_out)
 	sscanf(line, "info=r name=%s type=%s mode=%s %s version=%u",
 	       r_name, r_type, mode, sh_count, &ver);
 
-	/* when mode is not un, wait and print each lk line */
+	strcpy(r_name_out, r_name);
+	strcpy(r_type_out, r_type);
 
-	if (strcmp(mode, "un")) {
-		strcpy(r_name_out, r_name);
-		strcpy(r_type_out, r_type);
+	/* when mode is not un, wait and print each lk line */
+	if (strcmp(mode, "un"))
 		return;
-	}
 
 	/* when mode is un, there will be no lk lines, so print now */
 
@@ -229,7 +228,7 @@ static void format_info_r_action(char *line, char *r_name, char *r_type)
 	find_client_info(client_id, &pid, cl_name);
 
 	if (strcmp(op, "lock")) {
-		printf("OP %s pid %u (%s)", op, pid, cl_name);
+		printf("OP %s pid %u (%s)\n", op, pid, cl_name);
 		return;
 	}
 


