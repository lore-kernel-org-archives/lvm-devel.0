From: Petr Rockai <prockai@redhat.com>
Date: Tue, 17 Mar 2009 09:29:07 +0100
Subject: [PATCH] lvchange -a y does not need a write lock
Message-ID: <87ocw0lfho.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a trivial patch in itself, but it depends on my version of "[PATCH] Fix
segfault when using vgsplit in stacked environment" (attached again for
completeness) which in turn depends on the vg_read patches that are stuck
somewhere in the middle of review/application.

This patch is mostly useful for the ignorelockingfailed re-implementation that
can be found yet elsewhere in the list (for explanation, see below). I am also
attaching that patch for reference.

Unfortunately, as things are, all this blocks on the vg_read patches. As for
merit of the ignorelockingfailed patches (with or without this addition), we
can probably discuss that when vg_read is sorted somehow.

Either way, this mini-patch fixes Dave's concern about lvchange:

Dave Wysochanski <dwysocha@redhat.com> writes:
> * Then again, lvchange and vgchange seem to have different code for
> changing availability of an LV (?) so there may be a subtle reason
> lvchange always takes a WRITE lock.

Since for the segfault fix mentioned earlier, we need to let lvchange/vgchange
set handles_missing_pvs (since it really does), we already know that we are
only going to do activation (and nothing else) in lvchange, in which case, we
can as well ask for a read-only lock (since we aren't going to do any metadata
writes).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvchange-activate-no-write-lock.diff
Type: text/x-diff
Size: 619 bytes
Desc: lvchange-activate-no-write-lock.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090317/a7b7f1b7/attachment.bin>
-------------- next part --------------
 
This is the "Fix segfault when using vgsplit in stacked environment" one:
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-vg_read-missing_pvs.diff
Type: text/x-diff
Size: 4043 bytes
Desc: lvm-vg_read-missing_pvs.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090317/a7b7f1b7/attachment-0001.bin>
-------------- next part --------------

And this is the ignorelockingfailure re-implementation:
-------------- next part --------------
A non-text attachment was scrubbed...
Name: ignorelockingfailure.diff
Type: text/x-diff
Size: 6281 bytes
Desc: ignorelockingfailure.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090317/a7b7f1b7/attachment-0002.bin>
-------------- next part --------------


-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
