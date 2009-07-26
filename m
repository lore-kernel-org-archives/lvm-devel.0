From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 26 Jul 2009 15:13:05 -0400
Subject: [PATCH 3/4] Update test/api/test.c to call lv_deactivate and lv_activate.
In-Reply-To: <1248635586-8139-3-git-send-email-dwysocha@redhat.com>
References: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-2-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1248635586-8139-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 289278d..a97a192 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -50,6 +50,10 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 
 static void _show_help(void)
 {
+	printf("'lv_activate vgname lvname: "
+	       "Activate an LV\n");
+	printf("'lv_deactivate vgname lvname: "
+	       "Deactivate an LV\n");
 	printf("'vg_remove_lv vgname lvname': "
 	       "Remove a LV\n");
 	printf("'vg_create_lv_linear vgname lvname size_in_bytes': "
@@ -317,6 +321,42 @@ static void _lvs_in_vg(char **argv, int argc)
 	}
 }
 
+static void _lv_deactivate(char **argv, int argc)
+{
+	lv_t *lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (!lvm_lv_deactivate(lv))
+		printf("Error ");
+	else {
+		printf("Success ");
+	}
+	printf("De-activating LV %s in VG %s\n",
+		argv[2], argv[1]);
+}
+static void _lv_activate(char **argv, int argc)
+{
+	lv_t *lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (!lvm_lv_activate(lv))
+		printf("Error ");
+	else {
+		printf("Success ");
+	}
+	printf("activating LV %s in VG %s\n",
+		argv[2], argv[1]);
+}
 static void _vg_remove_lv(char **argv, int argc)
 {
 	lv_t *lv;
@@ -404,6 +444,10 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {
 			_vg_close(argv, argc);
+		} else if (!strcmp(argv[0], "lv_activate")) {
+			_lv_activate(argv, argc);
+		} else if (!strcmp(argv[0], "lv_deactivate")) {
+			_lv_deactivate(argv, argc);
 		} else if (!strcmp(argv[0], "vg_remove_lv")) {
 			_vg_remove_lv(argv, argc);
 		} else if (!strcmp(argv[0], "vgs_open")) {
-- 
1.6.0.6


