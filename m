From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Aug 2022 11:34:13 +0000 (GMT)
Subject: main - vdo: use only verbose log level for reformating
Message-ID: <20220815113413.41BC03858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc5bc5985d03aef5846cb98882d17815fc00ca15
Commit:        fc5bc5985d03aef5846cb98882d17815fc00ca15
Parent:        d0697be5004af0e040b1f746e619b8075350bc46
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 15 13:08:59 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 15 13:32:55 2022 +0200

vdo: use only verbose log level for reformating

When lvcreate is makeing VDO pool and user has not specified -V size,
ATM we actually run  'vdoformat' twice to get properly 'extent' aligned
size matching lvm2 properties - so the 2nd. run of vdoformat actually
can stay with 'log_verbose()' so the standard printed result
is not showing confusing info (which is now also correctly using
print_unless_silent)
---
 lib/metadata/vdo_manip.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 4ccde40b1..637fd1e5d 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -249,6 +249,7 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 	FILE *f;
 	uint64_t lb;
 	unsigned slabbits;
+	unsigned reformating = 0;
 	int args = 1;
 	char buf_args[5][128];
 	char buf[256]; /* buffer for short disk header (64B) */
@@ -351,8 +352,12 @@ reformat:
 			}
 		if ((c = strchr(buf, '\n')))
 			*c = 0; /* cut last '\n' away */
-		if (buf[0])
-			log_print("  %s", buf); /* Print vdo_format messages */
+		if (buf[0]) {
+			if (reformating)
+				log_verbose("  %s", buf); /* Print vdo_format messages */
+			else
+				log_print_unless_silent("  %s", buf); /* Print vdo_format messages */
+		}
 	}
 
 	if (!pipe_close(&pdata)) {
@@ -372,6 +377,7 @@ reformat:
 			*logical_size = logical_size_aligned;
 			argv[1] = (char*) "--force";
 			args = 2;
+			reformating = 1;
 			log_verbose("Reformating VDO to align virtual size %s by extent size.",
 				    display_size(data_lv->vg->cmd, *logical_size));
 			goto reformat;

