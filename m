From: Petr Rockai <prockai@redhat.com>
Date: Sun, 29 Nov 2009 20:26:49 +0100
Subject: [PATCH] Optionally abort on internal errors.
Message-ID: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

a fairly straightforward patch adding a configure option that will
abort() the process in case it encounters an internal
error. Undocumented so far and not sure it's appropriate to expose --
but maybe we have a policy of no undocumented options?

Anyway, patch attached. (It also makes the testsuite set this option, so
it'll catch any internal errors that may happen during the tests.)

Yours,
    Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: internal-errors.diff
Type: text/x-diff
Size: 3081 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091129/c5c559a0/attachment.bin>
