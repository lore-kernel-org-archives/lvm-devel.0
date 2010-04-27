From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Apr 2010 17:14:59 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
Message-ID: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a first iteration of the transient-error handling in
lvconvert. This works by marking LVs as partial even though there are no
PVs missing -- whenever a mirror marks a leg or log as failed (in the
status string). The downside of this approach is that we never figure
which PV is failing, but that would require kernel-level support for IO
error tracking.

Yours,
   Petr.

PS: The test is rather rudimentary. On one hand, testing log failures
seems impossible because that runs into kernel lockups. I will add more
test scenarios for leg failures later, and also for leg replacement.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-transient.diff
Type: text/x-diff
Size: 24993 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100427/a839fbb6/attachment.bin>
