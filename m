From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 30 Jan 2015 10:14:33 +0100
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <87oapgiu3z.fsf@red.mvo.lan>
References: <87r3udicy7.fsf@red.mvo.lan>,
	<20150129200344.GO23957@agk-dp.fab.redhat.com>
	<87oapgiu3z.fsf@red.mvo.lan>
Message-ID: <54CB4B79.8000005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2015 08:51 AM, Marius Vollmer wrote:
> Alasdair G Kergon <agk@redhat.com> writes:
> 
>> Sounds like we forgot to update the library code to use the new method...
> 
> I filed a bug for this:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=1187481
> 

Unfortunately, this was a regression introduced in LVM2 v115. It should
be fixed now (https://bugzilla.redhat.com/show_bug.cgi?id=1187481#c2).

> Let us know how we are going to fix this.  If lvm2app is really a lost
> cause, we can change storaged to fork lvs etc and parse it's output.

I wouldn't say lvm2app is unusable, it's just not as maintained and
refreshed as direct LVM tools. The bug above was just a silly regression
that happened (yes, we should add full test coverage to lvm2app - that's
currently missing, I admit).

Also, recently, we've added tons of new fields, also fields for
reporting each attribute in its own field so you have easier job
when parsing the output (see lvs/vgs/pvs -o help). However,
some of these new fields doesn't have lvm2app hooks yet written -
they're going to be added soon.
-- 
Peter


