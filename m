From: Petr Rockai <prockai@redhat.com>
Date: Wed, 27 Oct 2010 01:37:44 +0200
Subject: [PATCH] Fix a double close() in clvmd (fixing another deadlock bug)
Message-ID: <87fwvs1q5z.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

while working on 561226, I ran into another deadlock in clvmd. Again, it
may or may not be the same as reported in the aforementioned bug.

Nevertheless, this is what was going on: the management threads
(main_loop, the socket thread) could close a single fd twice in a row
sometimes. This wouldn't be such a tragedy in a single-threaded
application, the latter close would normally just fail (although there
is still plenty of scenarios where even in a single-threaded program,
this code could lead to a spectacular failure).

Anyway, at least one other thread can be running at the same time as the
threads doing the double close. That one running thread also happens to
do some IO (namely, open /proc/devices, read from it, close it). If
there was enough "demand" on the socket, this could happen:

- a connection to clvmd is about to finish, let's say the fd is 13 (it
  often happens to be in my test script, don't ask why)
- the local_sock thread calls close(13)
- the lvm thread calls open("/proc/devices"...) and gets 13
- the main_loop thread calls close(13) [OOPS!]
- new connection arrives, and is accept'd by a (new) local_sock thread
- the accept gives an fd of 13 (since it's the lowest free fd at this point)
- the lvm thread gets around to read from it's /proc/devices
  handle... 13, again
- the lvm thread hangs forever trying to read from the socket instead
  from /proc/devices

The attached patch should fix the problem.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: clvmd-double-close.diff
Type: text/x-diff
Size: 905 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101027/9d8b7d4f/attachment.bin>
-------------- next part --------------

Yours,
   Petr.
