From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 20 May 2010 07:54:21 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87bpcbf2cl.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>	<4BEDD432.4010800@redhat.com>
	<4BF1CAD9.1050005@redhat.com>	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>	<4BF3FE5C.8070906@redhat.com>	<874oi34ubd.fsf@twilight.int.mornfall.net.>	<4BF4872B.5060204@redhat.com>
	<87bpcbf2cl.fsf@twilight.int.mornfall.net.>
Message-ID: <4BF522ED.4040201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,
Petr Rockai wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
>>> Please test and let me know if you run into any other issues.
>> I tested your two patches and all my test cases for 'disk' log
>> passed. As for 'mirrored' log, we need to check the state for
>> log_lv. Here is the sample code.
> 
> So, do you think it is reasonable to check this in in its current form,
> and work on --repair support for mirrored logs in a separate patch?

That sounds reasonable to me.

> I think there are currently other things broken wrt. mirrored log and
> --repair, other than just the transient support, and I'll have to sit
> down and write tests first to see what works and what doesn't and then
> fix things up.

I will review & test a patch is ready.

Thanks,
Taka


