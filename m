From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 29 Jan 2015 21:46:39 +0100
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <87pp9xibcz.fsf@red.mvo.lan>
References: <87r3udicy7.fsf@red.mvo.lan>,
	<20150129200344.GO23957@agk-dp.fab.redhat.com>
	<87pp9xibcz.fsf@red.mvo.lan>
Message-ID: <54CA9C2F.6090708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.1.2015 v 21:24 Marius Vollmer napsal(a):
>
> Alasdair G Kergon <agk@redhat.com> writes:
>
>> On Thu, Jan 29, 2015 at 09:50:08PM +0200, Marius Vollmer wrote:
>>> at one moment lvm_lv_get_property returned a valid and useful "lv_attr"
>>> property, and then suddenly it returns values with "is_valid == 0".
>>
>> The way some of the properties are gathered got changed.
>>
>> Sounds like we forgot to update the library code to use the new method...
>
> I found this:
>
>      /* backward compatible internal API for lvm2api, TODO improve it */
>      char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
>
> Guys, really.  Write some tests.
>


Hi


lvm2api is rather purely experimental part of lvm2 - it has no real maintainer
and no real plans on further development ATM.

I'd strongly recommend to use lvm2 commands - since they are far more 
optimized and tested.

lvm2api at current stage has huge list of hardly resolvable issues and some 
new way has to be used to fix them (likely some 'client/server' model)

Regards

Zdenek




