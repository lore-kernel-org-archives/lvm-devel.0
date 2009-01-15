From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 15 Jan 2009 16:32:20 -0500
Subject: [RFC PATCH]: Remove vg_might_exist() and let the caller decide the disposition of FAILED_NOTFOUND.
Message-ID: <1232055140.14288.19.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter, this should apply on top of your 11 vg_read() patches posted
1-12-2009.  I've been thinking about ways to clean up vg_might_exist()
and this is one potential route but has a downside.

It makes the code simpler and more readable but does have one shortfall.
Normally when a VG does not exist we print an error message to this
effect.  This patch removes the message.  One approach is to add another
flag (ugh - we just removed one) to this effect.

Might not be possible this go around but perhaps this is close enough to
spur some thoughts of how we could clean this up.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Remove-vg_might_exist-and-let-the-caller-decide-th.patch
Type: application/mbox
Size: 6664 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090115/0a248e58/attachment.mbox>
