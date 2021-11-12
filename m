From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Nov 2021 18:27:05 +0000 (GMT)
Subject: main - online files: fix vgname check
Message-ID: <20211112182705.9B443385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66f0fe57c3b376672696e3e7f4fe9e691a06d482
Commit:        66f0fe57c3b376672696e3e7f4fe9e691a06d482
Parent:        5dbf316cee12484ad701367ff519bebe1523ef9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 12 11:52:36 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 12 11:52:36 2021 -0600

online files: fix vgname check

The pvs_online file for a PV will not contain a vgname
if the PV has no metadata, so don't require matching
vgname with the pvs_lookup file.
---
 lib/device/online.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/lib/device/online.c b/lib/device/online.c
index c67f45001..024485bb3 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -415,8 +415,17 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname, file_devname))
 			goto_bad;
 
-		if (vgname && strcmp(file_vgname, vgname))
+		/*
+		 * PVs without metadata will not have a vgname in their pvid
+		 * file, but the purpose of using the lookup file is that we
+		 * know the PV is for this VG even without the pvid vgname
+		 * field.
+		 */
+		if (vgname && file_vgname[0] && strcmp(file_vgname, vgname)) {
+			/* Should never happen */
+			log_error("Incorrect VG lookup file %s PVID %s %s.", vgname, pvid, file_vgname);
 			goto_bad;
+		}
 
 		if (!(po = zalloc(sizeof(*po))))
 			goto_bad;


