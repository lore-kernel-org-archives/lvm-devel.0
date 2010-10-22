From: Petr Rockai <prockai@redhat.com>
Date: Fri, 22 Oct 2010 10:59:56 +0200
Subject: [PATCH 4/4] Update tests for lvseg apis.
In-Reply-To: <4CC14AB6.9030407@redhat.com> (Zdenek Kabelac's message of "Fri, 
	22 Oct 2010 10:26:30 +0200")
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-5-git-send-email-dwysocha@redhat.com>
	<4CBEDBCE.1060400@redhat.com>
	<87zku75wmo.fsf@twilight.int.mornfall.net.>
	<4CC14AB6.9030407@redhat.com>
Message-ID: <87lj5q61rn.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:
>>> And I think using pointer would be wise decision here.
>> Care to elaborate? What's wise about using a pointer here?
>
> (const struct lvm_proper_value *v)
>
> avoid doing local copy of the 'v' structure - currently it's not a big
> difference, but as you pointed out in other emails - it could be extended in
> future. And I think we are using  pointers in other calls as well - so we
> should stay consistent also internally - and just pass pointers all the time -
> instead of thinking when to use struct and when the pointer should be passed.

Unlike object lifetime, this is something that the compiler can check
statically. Moreover, it may or may not be more efficient to pass a
pointer. Usually it's not, unless the structure is big and/or the
compiler optimisations poor.

Passing a value is prone to fewer errors. I vote for a value. (We should
aim to pass values whenever possible, IMHO. Those vg_t/pv_t/lv_t behave
as values as well, in this respect.)

Yours,
   Petr.


