From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 2 Nov 2009 08:51:45 -0600
Subject: [PATCH]: Enable snapshots of mirrors
In-Reply-To: <87iqdusaf6.fsf@twilight.int.mornfall.net.>
References: <1256237661.14726.3.camel@hydrogen.msp.redhat.com>
	<87iqdusaf6.fsf@twilight.int.mornfall.net.>
Message-ID: <402441FE-7AEF-48E4-81DC-817BB004E24B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ok, thanks for the reminder!

  brassow

On Nov 1, 2009, at 6:21 AM, Petr Rockai wrote:

> Hi,
>
> it would be great if you could convert your tests into actual  
> testcase code,
> maybe gathered all under test/t-snapshots-of-mirrors.sh -- this  
> would help
> prevent any possible regressions in the future. It would also mean  
> we remember
> all the information you needed to gather to conduct these tests.
>
> May you need any assistance with writing the tests, please don't  
> hesitate to
> contact me (IRC probably works best).
>
> Also,
>
> Jonathan Brassow <jbrassow@redhat.com> writes:
>> lvconvert:
>> + down convert works (mirror to linear)
>> + down convert works (mirror to mirror)
>> + up convert works (linear to mirror) - both background and  
>> foreground
>> - up convert doesn't work (mirror to mirror) - disabled in  
>> lvconvert and
>> err msg added
>> + convert between log types works (core <-> disk/redundant)
> could you please check what lvconvert --repair does under a  
> snapshot? I would
> probably look into the mirror->mirror upconversion, although that's  
> only
> relevant for a repair of 3+-way mirror.
>
> The t-lvconvert-repair.sh script should aid you in constructing a  
> testcase.
>
> Thanks!
>   Petr.
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


