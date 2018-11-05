From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:41 -0500
Subject: master - debug: tracing fclose failure
Message-ID: <201811051627.wA5GRf9J005486@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d9979963ffa5ec72a188e123a89eeea8ea666c5
Commit:        9d9979963ffa5ec72a188e123a89eeea8ea666c5
Parent:        aa8b2d6a0feb91bb5ea4364cdc53a00dfa233dca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:00:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 5 17:25:11 2018 +0100

debug: tracing fclose failure

Using log_debug (not returning error code) to trace possible
failure of fclose().
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index d22d009..993f2f5 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -307,7 +307,8 @@ static int read_host_id_file(void)
 		}
 	}
 	if (fclose(file))
-		log_error("failed to close host id file %s", daemon_host_id_file);
+		log_debug("Failed to fclose host id file %s (%s).",
+			  daemon_host_id_file, strerror(errno));
 out:
 	log_debug("host_id %d from %s", host_id, daemon_host_id_file);
 	return host_id;
@@ -365,7 +366,9 @@ static void _read_sysfs_size(dev_t devno, const char *name, unsigned int *val)
 	if (strlen(buf))
 		*val = atoi(buf);
 out:
-	fclose(fp);
+	if (fclose(fp))
+		log_debug("Failed to fclose host id file %s (%s).", path, strerror(errno));
+
 }
 
 /* Select sector/align size for a new VG based on what the device reports for


