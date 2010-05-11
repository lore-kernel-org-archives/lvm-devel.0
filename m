From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 May 2010 08:36:10 -0400
Subject: [PATCH 6/6] Test lvm_vgname_from_{pvid|device}.
In-Reply-To: <1273581370-13528-6-git-send-email-dwysocha@redhat.com>
References: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-2-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-3-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-4-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-5-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1273581370-13528-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 8775dfb..f89840c 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -97,6 +97,10 @@ static void _show_help(void)
 	       "Add/remove a tag from a VG\n");
 	printf("'lv_{add|remove}_tag vgname lvname tag': "
 	       "Add/remove a tag from a LV\n");
+	printf("'vgname_from_devname device': "
+	       "Lookup a vgname from a device name\n");
+	printf("'vgname_from_pvid pvid': "
+	       "Lookup a vgname from a pvid\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -576,6 +580,38 @@ static void _lv_tag(char **argv, int argc, int add)
 	printf("%s tag %s to LV %s\n",
 	       add ? "adding":"removing", argv[3], argv[2]);
 }
+static void _vgname_from_pvid(char **argv, int argc, lvm_t libh)
+{
+	const char *vgname;
+
+	if (argc < 1) {
+		printf("Please enter pvid\n");
+		return;
+	}
+	if (!(vgname = lvm_vgname_from_pvid(libh, argv[1]))) {
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("looking up vgname=%s from PVID=%s\n",
+	       vgname, argv[1]);
+}
+static void _vgname_from_devname(char **argv, int argc, lvm_t libh)
+{
+	const char *vgname;
+
+	if (argc < 1) {
+		printf("Please enter device\n");
+		return;
+	}
+	if (!(vgname = lvm_vgname_from_device(libh, argv[1]))) {
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("looking up vgname=%s from device name=%s\n",
+	       vgname, argv[1]);
+}
 static void _lvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *lvs;
@@ -766,6 +802,10 @@ static int lvmapi_test_shell(lvm_t libh)
 			_lv_tag(argv, argc, 0);
 		} else if (!strcmp(argv[0], "lv_get_tags")) {
 			_lv_get_tags(argv, argc);
+		} else if (!strcmp(argv[0], "vgname_from_devname")) {
+			_vgname_from_devname(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vgname_from_pvid")) {
+			_vgname_from_pvid(argv, argc, libh);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}
-- 
1.6.0.6


