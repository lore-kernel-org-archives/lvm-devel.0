From: Petr Rockai <prockai@redhat.com>
Date: Thu, 19 Nov 2009 01:11:18 +0100
Subject: [PATCH] Separate the memlock counters for in-command use and for dmeventd.
Message-ID: <874oorxtjt.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is basically the other half of bug 537942 -- the first half I have
committed a few hours ago. This one however needs some review, since
it's a little late by European standards and I'd rather not break the
memlock refcounting code completely.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: memlock.diff
Type: text/x-diff
Size: 3073 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091119/a6800235/attachment.bin>
-------------- next part --------------

Yours,
   Petr.
