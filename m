From: Petr Rockai <prockai@redhat.com>
Date: Tue, 29 Jul 2008 15:48:06 +0200
Subject: [PATCH] (5/6) lvconvert --repair
Message-ID: <87tze8244p.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Not many changes have happened here either. However, with the changes in
underlying code (in the foundation patches, mostly), I am declaring this to be
no longer experimental and I hereby declare my intent to have this merged as
well (maybe not right away along the rest of the patches, as this is apparently
the least scrutinised one, but soon enough, as this opens the path for
important dmeventd functionality (that is, hotspare substitution of mirror
devices).

(This here is the proposed new way for dmeventd to handle partial mirror
failures, which will do as before -- remove lost legs/disklog, moreover, if
available, it will replace them with freshly allocated areas... This needs to
be more controlled eventually, but I think what we have here is a good start.)

diff -rN -p -u old-hotspare-everything/dmeventd/mirror/dmeventd_mirror.c new-hotspare-everything/dmeventd/mirror/dmeventd_mirror.c
--- old-hotspare-everything/dmeventd/mirror/dmeventd_mirror.c   2008-07-29 15:26:44.161493573 +0200
+++ new-hotspare-everything/dmeventd/mirror/dmeventd_mirror.c   2008-07-29 15:26:44.185490029 +0200
@@ -152,7 +152,7 @@ static int _remove_failed_devices(const 
        }
 
        /* FIXME Is any sanity-checking required on %s? */
-       if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --config devices{ignore_suspended_devices=1} --removemissing %s", vg)) {
+       if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair '%s/%s'", vg, lv)) {
                /* this error should be caught above, but doesn't hurt to check again */
                syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
                dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */

The actual patch for lvconvert follows.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair.diff
Type: text/x-diff
Size: 15389 bytes
Desc: lvconvert-repair.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080729/a2034d9b/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
