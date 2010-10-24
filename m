From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 24 Oct 2010 18:24:00 +0200
Subject: [PATCH 4/4] Update tests for lvseg apis.
In-Reply-To: <87lj5q61rn.fsf@twilight.int.mornfall.net.>
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>	<1287494696-18310-5-git-send-email-dwysocha@redhat.com>	<4CBEDBCE.1060400@redhat.com>	<87zku75wmo.fsf@twilight.int.mornfall.net.>	<4CC14AB6.9030407@redhat.com>
	<87lj5q61rn.fsf@twilight.int.mornfall.net.>
Message-ID: <4CC45DA0.4030509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.10.2010 10:59, Petr Rockai napsal(a):
> Zdenek Kabelac <zkabelac@redhat.com> writes:
>>>> And I think using pointer would be wise decision here.
>>> Care to elaborate? What's wise about using a pointer here?
>>
>> (const struct lvm_proper_value *v)
>>
>> avoid doing local copy of the 'v' structure - currently it's not a big
>> difference, but as you pointed out in other emails - it could be extended in
>> future. And I think we are using  pointers in other calls as well - so we
>> should stay consistent also internally - and just pass pointers all the time -
>> instead of thinking when to use struct and when the pointer should be passed.
> 
> Unlike object lifetime, this is something that the compiler can check
> statically. Moreover, it may or may not be more efficient to pass a
> pointer. Usually it's not, unless the structure is big and/or the
> compiler optimisations poor.
> 
> Passing a value is prone to fewer errors. I vote for a value. (We should
> aim to pass values whenever possible, IMHO. Those vg_t/pv_t/lv_t behave
> as values as well, in this respect.)
> 

I'm not going to argue whether it's more or less efficient as in this case it
will make no difference.  But passing things by value is simply very hardly
supportable by dso libraries - and usually require complete rebuild of binary
to use updated library. Also you would need to remember where are you using
passing by value - and in case structure size grows - rewrite many functions
to switch to pointers - why not do that right from the beginning? -  I'd pass
by value only the language atomic/basic types - definitely not any structure
where even you are pointing out future extensions in other post.

BTW: I don't take vg_t/pv_t/lv_t as an an argument for passing things by value
as it's nothing else that syntactical sugar for pointers - and in fact I'd not
any objections against exactly same strategy for properties - making property
object completely private structure to lvm and give the API user only handle
lvm_property_t and set of function for this handle (C++ in C :))
(i.e.
lvm_property_is_string/get_string/is_integer/get_integer(lvm_property_t...)

Zdenek


