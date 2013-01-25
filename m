From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 25 Jan 2013 10:43:59 -0600
Subject: [RFC/PATCH 0/2] lvm2app: Adding lv creation support
In-Reply-To: <87ham5jygw.fsf@in.ibm.com>
References: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
	<5101C449.60304@redhat.com> <87ham5jygw.fsf@in.ibm.com>
Message-ID: <5102B64F.4020104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/25/2013 05:25 AM, M. Mohan Kumar wrote:
> Tony Asleson <tasleson@redhat.com> writes:
>> This patch looks pretty straight forward.  Ideally we would not have the
>> function do the write and commit to match the other functions.  Did you
>> happen to take a peek to what that would involve?
>>
> This function is based on existing function
> lvm_vg_create_lv_linear. This existing function does not call
> lvm_vg_write.  or am I missing something here?

The existing lvm_vg_create_lv_linear indirectly does a vg_write and
vg_commit.  Look at function _lv_create_an_lv in lib/metadata/lv_manip.c

I took a look at this and it won't be easy.  I should have looked at
lvm_vg_create_linear as Dave has a nice comment on the function about
the difficulty in changing this behavior.

> I need to modify some of the validation as it was not needed in case of
> parameter passed by user.

I think before we integrate a patch like this we should address the code
duplication part.  Otherwise we are making the code base incrementally
messier rather than incrementally better :-)  At the moment I'm not sure
where common code like this should be placed.

Anyone have a suggestion?

>> Exposing parameter passing with the use of structures is typically
>> discouraged in a shared C API.  The struct padding can be different from
>> client application and library compile based on compiler settings.  If
>> we go this route we should at the very least do a pragma pack to
>> mitigate this.  In addition once you do this the structure forever
>> cannot change.  We could address these issues by creating an opaque data
>> type and then adding some functions to set/get the values from the
>> opaque handle.  Kind of tedious, but it is a common approach.
>>
>> Not sure what else we could do to offset the vast number of arguments
>> that are available.
>>
> 
> I agree, can we try something like this:
> lv_set_param(mirror, value_for_mirror, opaque structure);
> lv_set_param(region_size, value_for_region_size, opaque structure);

This would work, but I'm not sure what you were thinking about for
different types?  What happens when value_for* is a non numeric?  Is
mirror & region_size enumerated values?  Python or even C++ could handle
this easily, but without throwing out type safety I'm not sure about C.
 My initial simple thought was something more like:

int lv_param_mirror_set(opaque_data_type handle, int value);
int lv_param_mirror_get(opaque_data_type handle);

Historically I have seen the opaque structure pointer first in the
argument list (kind of like the this pointer), but it will work fine
either way :-)

Thanks,
-Tony


