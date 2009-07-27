From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:49 -0400
Subject: [PATCH] Add config_reload and config_override to test.c.
In-Reply-To: <1248724909-20369-6-git-send-email-dwysocha@redhat.com>
References: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-2-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-3-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-4-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-5-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1248724909-20369-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

  PV         PV UUID                                VG
  /dev/loop1 A95EvV-iqmb-ZFuJ-u8MV-Npwn-wlc2-Ul1Mnn vg1
  /dev/loop0 R16FDG-OmoS-HNGt-LSZY-OAlC-7qeU-t2gztp vg1
lvm> config_override loop0
Success overriding LVM configuration
lvm> config_reload
Success reloading LVM configuration
lvm> vg_open vg1
Couldn't find device with uuid 'A95EvV-iqmb-ZFuJ-u8MV-Npwn-wlc2-Ul1Mnn'.
Success opening vg vg1
lvm> vg_close vg1
lvm> quit

Maybe a bug in lvm_vg_open for missing pvs but the filter seems to work.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 3234beb..7ed339b 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -80,6 +80,10 @@ static void _show_help(void)
 	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
 	printf("'vg_close vgname': "
 	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'config_reload': "
+	       "Issue a lvm_config_reload() API to reload LVM config\n");
+	printf("'config_override' device: "
+	       "Issue a lvm_config_override() with accept device filter\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -221,6 +225,35 @@ static void _vg_reduce(char **argv, int argc, lvm_t libh)
 		_remove_device_from_pvname_hash(pvs, argv[2]);
 }
 
+static void _config_override(char **argv, int argc, lvm_t libh)
+{
+	int rc;
+	char tmp[64];
+
+	if (argc < 2) {
+		printf ("Please enter device\n");
+		return;
+	}
+	snprintf(tmp, 63, "devices{filter=[\"a|%s|\", \"r|.*|\"]}", argv[1]);
+	rc = lvm_config_override(libh, tmp);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("overriding LVM configuration\n");
+}
+
+static void _config_reload(char **argv, int argc, lvm_t libh)
+{
+	int rc;
+	rc = lvm_config_reload(libh);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("reloading LVM configuration\n");
+}
+
 static void _vg_extend(char **argv, int argc, lvm_t libh)
 {
 	vg_t *vg;
@@ -521,6 +554,10 @@ static int lvmapi_test_shell(lvm_t libh)
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
 			_show_help();
+		} else if (!strcmp(argv[0], "config_reload")) {
+			_config_reload(argv, argc, libh);
+		} else if (!strcmp(argv[0], "config_override")) {
+			_config_override(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_extend")) {
 			_vg_extend(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_reduce")) {
-- 
1.6.0.6


