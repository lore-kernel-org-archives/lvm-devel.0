From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 30 Jan 2015 10:42:43 +0100
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <87mw50ipfv.fsf@red.mvo.lan>
References: <87r3udicy7.fsf@red.mvo.lan>, <87oapgiu3z.fsf@red.mvo.lan>,
	<54CB4B79.8000005@redhat.com> <87mw50ipfv.fsf@red.mvo.lan>
Message-ID: <54CB5213.7030108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2015 10:32 AM, Marius Vollmer wrote:
> Peter Rajnoha <prajnoha@redhat.com> writes:
> 
>> Unfortunately, this was a regression introduced in LVM2 v115. It should
>> be fixed now (https://bugzilla.redhat.com/show_bug.cgi?id=1187481#c2).
> 
> Thanks!  (I think there is more to do, unfortunately, see the bug.)
> 

(yup, I'm looking at that now)

>> I wouldn't say lvm2app is unusable, it's just not as maintained and
>> refreshed as direct LVM tools. [...]
> 
> Do you know of any users besides storaged?
> 

Anaconda was one of the candidates to use liblvm, but afaik, they're
still forking LVM commands.

The other one I know of is the udisks, but it removed support for LVM
some time ago and udisks2 and later does not handle LVM anymore.

And then your use case :)

I don't know about more lvm2app users (but if anyone knows about more,
correct me) at the moment. That's also the reason why we (or I) don't
invest so much time into this and we spend this time on improving direct
LVM commands instead, I'd say.

> We should cooperate and make somehow sure that the storaged and Cockpit
> tests run for each LVM2 update...

...and we (LVM) should add more tests into our testsuite for the lvm2app.

-- 
Peter


