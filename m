From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:00 +0100
Subject: [PATCH 4/14] Replace implementation of vg_check_status with a call to _vg_check_status.
In-Reply-To: <1232619010-4858-4-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-5-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 10:38:04 CET 2009  Petr Rockai <me@mornfall.net>
  * Replace implementation of vg_check_status with a call to _vg_check_status.
diff -rN -u -p old-temp.4430/lib/metadata/metadata.c new-temp.4430/lib/metadata/metadata.c
--- old-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:38.798779559 +0100
+++ new-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:38.854780880 +0100
@@ -2420,31 +2420,7 @@ static uint32_t _vg_check_status(const s
  */
 int vg_check_status(const struct volume_group *vg, uint32_t status)
 {
-	if ((status & CLUSTERED) &&
-	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
-		return 0;
-	}
-
-	if ((status & EXPORTED_VG) &&
-	    (vg->status & EXPORTED_VG)) {
-		log_error("Volume group %s is exported", vg->name);
-		return 0;
-	}
-
-	if ((status & LVM_WRITE) &&
-	    !(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", vg->name);
-		return 0;
-	}
-	if ((status & RESIZEABLE_VG) &&
-	    !(vg->status & RESIZEABLE_VG)) {
-		log_error("Volume group %s is not resizeable.", vg->name);
-		return 0;
-	}
-
-	return 1;
+	return !_vg_check_status(vg, status);
 }
 
 /*


