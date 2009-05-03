From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:57 +0200
Subject: [PATCH 5/9] Don't segfault in vg_release when vg->cmd is NULL.
In-Reply-To: <1241350741-31349-5-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
	<1241350741-31349-5-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-6-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:06:14 CEST 2009  Petr Rockai <me@mornfall.net>
  * Don't segfault in vg_release when vg->cmd is NULL.
diff -rN -u -p old-temp.31080/lib/metadata/metadata.c new-temp.31080/lib/metadata/metadata.c
--- old-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:33.682235890 +0200
+++ new-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:33.734236563 +0200
@@ -2091,7 +2091,7 @@ void vg_release(struct volume_group *vg)
 	if (!vg || !vg->vgmem)
 		return;
 
-	if (vg->vgmem == vg->cmd->mem)
+	if (vg->cmd && vg->vgmem == vg->cmd->mem)
 		log_error("Internal error: global memory pool used for VG %s",
 			  vg->name);
 


