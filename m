From: Petr Rockai <prockai@redhat.com>
Date: Mon, 04 Oct 2010 18:42:03 +0200
Subject: [PATCH] Produce correct error in lvcreate of small snapshots (BZ 587063)
Message-ID: <87aamt52qs.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this should fix BZ 587063, by producing an intelligible error
message. Automated test included (test/t-lvcreate-small-snap.sh).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvcreate-small-snap.diff
Type: text/x-diff
Size: 2096 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101004/7f099285/attachment.bin>
-------------- next part --------------

Yours,
   Petr.
