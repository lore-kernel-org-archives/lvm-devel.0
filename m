From: Neil Brown <neilb@suse.de>
Date: Thu, 29 Apr 2010 17:01:40 +1000
Subject: dmeventd doesn't handle failures during mirror resync.
Message-ID: <20100429170140.777db964@notabene.brown>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi,
 I've been exploring the behaviour of dm-raid1 (particular in a clustered
environment) in response to various error conditions.

I was surprised to discover that while a normal write error is
handled properly - dmeventd runs 'lvconvert' to fix the array up,
this does not happen in response to a write error while syncing
the array.

If I arrange for the new device to die, then 
          lvconvert --repair --use-policies

will fix it up as I would expect, but dmeventd never asks it to do
this.

This seems to be a deliberate decision:  in _process_status_code 
in dmeventd_mirror.c, a status of 'F' will cause lvconvert to be
run while 'S' and 'R' (sync and read errors) will not.

Is there a reason for this?

I realise that the data is not at risk in the case of a sync error as the
dirty log records that the section of the array is out of sync so no
IO will be directed there.  However it seems to go against expectation.
Also, if you then stop the array (vgchange -an) without lvconvert being
run, and restart it (vgchange -ay) the restart will fail unless you use
--partial.
This would mean that a shutdown/reboot would probably leave the volume
inactive (as it seems init scripts don't tend to inculde --partial) which
is not what I would expect.

Can we change dmeventd to response to sync (and read) errors in the same
way that it responds to write errors?

Thanks,
NeilBrown


diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 4d2eee5..7c6ceb9 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -41,21 +41,20 @@ static int _process_status_code(const char status_code, const char *dev_name,
 	 *    R => Read - A read failure occurred, mirror data unaffected
 	 *    U => Unclassified failure (bug)
 	 */ 
-	if (status_code == 'F') {
+	if (status_code == 'F')
 		syslog(LOG_ERR, "%s device %s flush failed.",
 		       dev_type, dev_name);
-		r = ME_FAILURE;
-	} else if (status_code == 'S')
+	else if (status_code == 'S')
 		syslog(LOG_ERR, "%s device %s sync failed.",
 		       dev_type, dev_name);
 	else if (status_code == 'R')
 		syslog(LOG_ERR, "%s device %s read failed.",
 		       dev_type, dev_name);
-	else if (status_code != 'A') {
+	else if (status_code != 'A')
 		syslog(LOG_ERR, "%s device %s has failed (%c).",
 		       dev_type, dev_name, status_code);
+	if (status_code != 'A')
 		r = ME_FAILURE;
-	}
 
 	return r;
 }


