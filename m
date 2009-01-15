From: Petr Rockai <me@mornfall.net>
Date: Thu, 15 Jan 2009 11:34:40 +0100
Subject: [PATCH 2/6] Replace implementation of vg_check_status with a call to _vg_check_status.
In-Reply-To: <1232015684-23781-2-git-send-email-me@mornfall.net>
References: <1232015684-23781-1-git-send-email-me@mornfall.net>
	<1232015684-23781-2-git-send-email-me@mornfall.net>
Message-ID: <1232015684-23781-3-git-send-email-me@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 10:38:04 CET 2009  Petr Rockai <me@mornfall.net>
  * Replace implementation of vg_check_status with a call to _vg_check_status.
diff -rN -u -p old-temp.23590/lib/metadata/metadata.c new-temp.23590/lib/metadata/metadata.c
--- old-temp.23590/lib/metadata/metadata.c	2009-01-15 11:27:08.423748009 +0100
+++ new-temp.23590/lib/metadata/metadata.c	2009-01-15 11:27:08.471751247 +0100
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


