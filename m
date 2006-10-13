From: Patrick Caulfield <pcaulfie@redhat.com>
Date: Fri, 13 Oct 2006 10:58:54 +0100
Subject: [PATCH] for bz 210511 & 203983
Message-ID: <452F635E.2060809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It seems that vgsplit was not propogating the CLUSTERED flag onto the new VG.
-- 

patrick

Index: tools/vgsplit.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/vgsplit.c,v
retrieving revision 1.19
diff -u -p -r1.19 vgsplit.c
--- tools/vgsplit.c	2 Sep 2006 01:18:17 -0000	1.19
+++ tools/vgsplit.c	13 Oct 2006 09:57:03 -0000
@@ -302,6 +302,9 @@ int vgsplit(struct cmd_context *cmd, int

 	vg_to->status &= ~EXPORTED_VG;

+	if (vg_from->status & CLUSTERED)
+		vg_to->status |= CLUSTERED;
+
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
 		goto error;


