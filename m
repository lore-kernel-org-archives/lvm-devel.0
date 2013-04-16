From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 16 Apr 2013 14:44:15 -0500
Subject: [PATCH V4] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <5168268A.6040701@redhat.com>
References: <1363713892-14704-1-git-send-email-mohan@in.ibm.com>
	<515DF3F3.70004@redhat.com> <87zjx47x7a.fsf@in.ibm.com>
	<516800C9.8000505@redhat.com> <5168268A.6040701@redhat.com>
Message-ID: <516DAA0F.2090604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/12/2013 10:21 AM, Tony Asleson wrote:
> On 04/12/2013 07:40 AM, Zdenek Kabelac wrote:
>  > We really need here separate type of object to set all properties for
> thin.
>> (Since their amount will grow over the time) so you can't solve with any
>> bit field - this is not extensible.
>>
>> We need to create 'object' with properties, that can be controled in C++
>> like way - so we may extend it in future easily, without breaking API,
>> and leaving
>> 'old' unusable calls in the library.
> 
> I will take a swag at something early next week and post for people to
> review.  We need to get something in soon so that people can utilize the
> new thinp stuff.

Mohan, I'm having difficultly getting your patch to apply at the moment.
 I wanted to use it as the basis of this work.  Would you have time to
update your patch against head?

I was going to create a new opaque type, create a base initialize
function and then add get/set functions for items you have.  This would
then become the parameter to feed into the thinp functions.  I was going
to omit the low water mark for now.

I don't know off hand what all the possible parameters for the thin pool
creation vs. the thin lv creation, but from the patch it looks like thus
far there are more parameters when creating the thin pool?  Do we need
opaque parameters for the thin pool creation and the thin logical volume
creation?

You are more than welcome to take a pass at this too if you have the
bandwidth :-)

Thanks,
Tony


