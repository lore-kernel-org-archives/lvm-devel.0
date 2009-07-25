From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:20 -0400
Subject: [PATCH 11/11] Update test/api/test.c to call lvm_vg_create_lv_linear.
In-Reply-To: <1248480500-472-11-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
	<1248480500-472-6-git-send-email-dwysocha@redhat.com>
	<1248480500-472-7-git-send-email-dwysocha@redhat.com>
	<1248480500-472-8-git-send-email-dwysocha@redhat.com>
	<1248480500-472-9-git-send-email-dwysocha@redhat.com>
	<1248480500-472-10-git-send-email-dwysocha@redhat.com>
	<1248480500-472-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index a7d6bc6..38222fa 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -50,6 +50,8 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 
 static void _show_help(void)
 {
+	printf("'vg_create_lv_linear vgname size_in_sectors': "
+	       "Create a linear LV\n");
 	printf("'scan_vgs': "
 	       "Scan the system for LVM metadata\n");
 	printf("'vg_list_names': "
@@ -292,6 +294,22 @@ static void _lvs_in_vg(char **argv, int argc)
 	}
 }
 
+static void _vg_create_lv_linear(char **argv, int argc)
+{
+	vg_t *vg;
+	lv_t *lv;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	lv = lvm_vg_create_lv_linear(vg, argv[1], atol(argv[2]));
+	if (!lv)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("creating LV %s in VG %s\n",
+		argv[1], lvm_vg_get_name(vg));
+}
+
 static int lvmapi_test_shell(lvm_t libh)
 {
 	int argc;
@@ -349,6 +367,8 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_list_ids(libh);
 		} else if (!strcmp(argv[0], "scan_vgs")) {
 			_scan_vgs(libh);
+		} else if (!strcmp(argv[0], "vg_create_lv_linear")) {
+			_vg_create_lv_linear(argv, argc);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}
-- 
1.6.0.6


