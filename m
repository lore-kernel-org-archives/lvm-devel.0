From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 16:05:23 +0000 (UTC)
Subject: master - lvmlockctl: update command descriptions and add logging
Message-ID: <20150904160523.520A160703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c71af0895d4ea3c37bcb06f36eed69a7adcb5296
Commit:        c71af0895d4ea3c37bcb06f36eed69a7adcb5296
Parent:        b00ee99a21f3a6f502fc5d165b979af128e3b8b2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 11:01:25 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 11:05:13 2015 -0500

lvmlockctl: update command descriptions and add logging

The one line descriptions will match the man page.

Add a syslog entry when enabling/disabling the global lock
to help debugging.
---
 daemons/lvmlockd/lvmlockctl.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 14be4fc..d0d680a 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -599,14 +599,14 @@ static void print_usage(void)
 	printf("      Wait option for other commands.\n");
 	printf("--force | -f 0|1>\n");
 	printf("      Force option for other commands.\n");
-	printf("--kill | -k <vg_name>\n");
-	printf("      Kill access to the vg when sanlock cannot renew lease.\n");
-	printf("--drop | -r <vg_name>\n");
-	printf("      Clear locks for the vg after it has been killed and is no longer used.\n");
-	printf("--gl-enable <vg_name>\n");
-	printf("      Tell lvmlockd to enable the global lock in a sanlock vg.\n");
-	printf("--gl-disable <vg_name>\n");
-	printf("      Tell lvmlockd to disable the global lock in a sanlock vg.\n");
+	printf("--kill | -k <vgname>\n");
+	printf("      Kill access to the VG when sanlock cannot renew lease.\n");
+	printf("--drop | -r <vgname>\n");
+	printf("      Clear locks for the VG when it is unused after kill (-k).\n");
+	printf("--gl-enable | -E <vgname>\n");
+	printf("      Tell lvmlockd to enable the global lock in a sanlock VG.\n");
+	printf("--gl-disable | -D <vgname>\n");
+	printf("      Tell lvmlockd to disable the global lock in a sanlock VG.\n");
 	printf("--stop-lockspaces | -S\n");
 	printf("      Stop all lockspaces.\n");
 }
@@ -731,11 +731,13 @@ int main(int argc, char **argv)
 	}
 
 	if (gl_enable) {
+		syslog(LOG_INFO, "Enabling global lock in VG %s.", arg_vg_name);
 		rv = do_able("enable_gl");
 		goto out;
 	}
 
 	if (gl_disable) {
+		syslog(LOG_INFO, "Disabling global lock in VG %s.", arg_vg_name);
 		rv = do_able("disable_gl");
 		goto out;
 	}


