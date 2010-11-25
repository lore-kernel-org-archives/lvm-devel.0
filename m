From: Petr Rockai <prockai@redhat.com>
Date: Thu, 25 Nov 2010 13:51:41 +0100
Subject: [PATCH] Refactor handling of percent values (towards BZ 654441)
Message-ID: <87eia9o9b6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch changes over the percent handling in the code: it
folds all percent values into a single fixed-point value, instead of a
floating point and an enum. This simplifies existing code (no need to
pass around extra variable/parameter), while also making it possible to
expose the percent attributes through the lvm2app API as a single
integral value (this is BZ 654441).

The lvm2app patch will follow.

Yours,
   Petr.

PS: Passes the testsuite.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: percent-refactor.diff
Type: text/x-diff
Size: 32714 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101125/ae187aa8/attachment.bin>
