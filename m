From: Petr Rockai <prockai@redhat.com>
Date: Thu, 29 Jul 2010 21:54:31 +0200
Subject: [PATCH] Handle transient errors for mirrored log in lvconvert --repair
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228865B4@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Thu, 29 Jul 2010 14:07:51 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A59228865AB@USINDEVS02.corp.hds.com>
	<87zkxa6xnl.fsf@twilight.int.mornfall.net.>
	<5C30BE7ED8B03E448B2E104602D4848A59228865B4@USINDEVS02.corp.hds.com>
Message-ID: <87pqy66p3c.fsf_-_@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

Takahiro Yasui <takahiro.yasui@hds.com> writes:
> Yes, this solution is acceptable to me. As a long term, we can introduce
> a kind of logic to keep the information of a bad segment or device and
> extend cases for 'allocate' policy.
great. I am attaching a patch proposal that would implement the outlined
policy. I have tucked in a warning for a good measure.

The patch still needs some testing, which I'd appreciate if you could
carry out. I will be away from internet starting tomorrow noon CEST and
should be back approximately Tuesday evening next week (still CEST). I
am afraid I won't have more time for this until after I return.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-transient-mirroredlog.diff
Type: text/x-diff
Size: 3862 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100729/f4687d7b/attachment.bin>
