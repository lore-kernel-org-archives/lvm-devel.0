From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Nov 2016 17:08:58 +0100
Subject: pending clvmd patches
In-Reply-To: <m2d1hnwm0n.fsf@discipline.rit.edu>
References: <87a8crampc.fsf@lant.ki.iif.hu>
	<cf050105-a0bb-fc5f-d938-67b3ae0e4cd0@redhat.com>
	<87oa178rb7.fsf@lant.ki.iif.hu> <m2d1hnwm0n.fsf@discipline.rit.edu>
Message-ID: <49d3eec6-bc92-b456-2056-ad4a1c91cd35@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.11.2016 v 16:51 Andrew W Elble napsal(a):
>>>> clvmd: fix memory corruption
>>>> (https://www.redhat.com/archives/lvm-devel/2015-December/msg00056.html)
>>>
>>> Hmm, could you please provide the actual 'valgrind' report?
>>
>> Unfortunately no, I'm not affiliated with this patch and report.  Shall
>> I resend your query to Andrew Elble <aweits@rit.edu>?
>
> I'm here, it will take me some time to re-dig up the details on this.
>


Hi

If you will be redoing it - please do use build with --enable-valgrind-pool
(so the memory is better traced for internal memory pools)

And valgrind is executed with options:

--leak-check=full --track-origins=yes

Thanks


Zdenek


