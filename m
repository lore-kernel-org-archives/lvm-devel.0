From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 03 May 2013 15:29:21 +0200
Subject: [PATCH] RFC: lvm2app: Add thin and thin pool lv creation
In-Reply-To: <5182E7AC.1060903@redhat.com>
References: <1367263243-17331-1-git-send-email-tasleson@redhat.com>
	<51824A5E.5010603@redhat.com> <5182E7AC.1060903@redhat.com>
Message-ID: <5183BBB1.8040008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 3.5.2013 00:24, Tony Asleson napsal(a):
> On 05/02/2013 06:13 AM, Zdenek Kabelac wrote:
>> Dne 29.4.2013 21:20, Tony Asleson napsal(a):
>>> +lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const
>>> char *pool_name,
>>> +                                    const char *lvname, uint64_t size)
>>
>> Hmmm - here the vg doesn't remain unmodified - we use it's memory pool
>> for lvcp - so I'd prefer to use it here without 'const'
>
> In this case having the const or not actually doesn't matter to the
> compiler as we have a typedef'd structure pointer and thus the const is
> meaningless.  However, from a documentation standpoint I agree that the
> const should be removed.
>
> I'm actually thinking we should get rid of the typedef struct pointers
> so that we can actually use const correctly and have it enforced by the
> compiler.  However, this would break existing user code.
>

Yep, it's purely a hint for user, that passed object is being modified, as we 
are not in C++ :) there is not a really good way to enforce this on code level :)


>>> +int lvm_lv_params_skip_zero_get(lv_create_params_t params)
>>
>>
>> add const for '_get()'
>
> Yeah good idea, but again not enforced by the compiler unless we ditch
> typedef struct pointer.  Which we can do for this newly created structure.
>
>> Any API test case ?
>
> I had a simple little C program to try this code out, but I haven't
> created a test case.  I wanted to see if this approach would be
> acceptable to everyone before I go ahead and create the python bindings
> and add this to the unit test case.
>
> Zdenek, you appear good with this patch (except for a few minor
> changes), how about everyone else?

I guess it's worth to try to commit this and see what happens.

Zdenek


