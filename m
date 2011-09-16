From: Petr Rockai <prockai@redhat.com>
Date: Fri, 16 Sep 2011 11:56:48 +0200
Subject: [PATCH] Fix #734193: divisibility issues with striped mirrors
In-Reply-To: <4E724EB5.2030102@redhat.com> (Milan Broz's message of "Thu, 15
	Sep 2011 21:15:01 +0200")
References: <87vcsusz82.fsf@aldalome.int.mornfall.net.>
	<4E724EB5.2030102@redhat.com>
Message-ID: <87r53gu7xb.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:

> On 09/15/2011 03:37 PM, Petr Rockai wrote:
>> the divisibility requirement in the allocation code is needlessly (and
>> incorrectly) strict, accounting not only for stripe layout but also for
>> mirrors (which do not divide extents among themselves, though). The
>> attached patch should remedy that. Regression test included.
>
> The former reason for this line was, I think it still applies
> https://bugzilla.redhat.com/show_bug.cgi?id=707779
>
> If so, ack.

Yes, it's required that extent count is divisible by stripe count: any
other setup would make little sense (since part of the LV would have a
different stripe count than the rest, which sounds like a really bad
idea, even if the allocator could cope with the request).

The 707779 case is accounted for by the last test in t-lvconvert-mirror,
which I think you added. Since it still passes after this patch, I am
going ahead and checking it in.

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


