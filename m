From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Nov 2010 19:40:06 +0100
Subject: [PATCH] require certain lvconvert operations to be done in 2 steps (BZ 640051)
Message-ID: <87sjyz23qx.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch disallows certain ambiguous (and buggy) invocations
of lvconvert. We have chatted on IRC with Alasdair, and the conclusion
was that it's better to disallow this (at least for now): expressing
such commands in a single request is likely to have confusing and
unexpected behaviour for many users.

(The operations that are not allowed anymore is removing and adding
devices to a mirror at the same time, while specifying the devices to be
added/removed. We do not have syntax for distinguishing which devices
should be added and which removed and even the "obvious" interpretation
has problems. That is, if a device is in mirror, remove it and if it is
not, add it -- it is not clear whether to treat removed devices as
candidates for additions, and both variants would make sense in
different contexts. It is also not clear in what order to do the
removals/additions: the best route may be different in different
scenarios again.)

I am also attaching a test for the behaviour. Turns out that even this
trivial patch had bugs (that the test caught).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-twostep.diff
Type: text/x-diff
Size: 2138 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101117/ec170f9f/attachment.bin>
