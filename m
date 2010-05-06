From: Petr Rockai <prockai@redhat.com>
Date: Thu, 06 May 2010 19:30:26 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87pr1kai2k.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 27 Apr 2010 20:03:47 +0200")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
Message-ID: <87y6fxos3x.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have rebased the patch against current CVS. Also, I have added a guard
to _mirrored_transient_status to ensure that we alloca() only very
modest (and, more importantly, bounded) amount of memory.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-transient.diff
Type: text/x-diff
Size: 24041 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100506/a5c0eb27/attachment.bin>
-------------- next part --------------

Yours,
    Petr.
