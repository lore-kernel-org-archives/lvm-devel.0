From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Sep 2011 13:34:36 +0200
Subject: [PATCH] Fix #733320: fix rounding inconsistency between lvresize/lvreduce
Message-ID: <87zki6t4xf.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

we wan to round in the safe direction, regardless of whether we were
called as lvresize or lvreduce. The attached patch implements that (and
adds a regression test).

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvresize-rounding.diff
Type: text/x-diff
Size: 1826 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110915/6fdb8180/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
