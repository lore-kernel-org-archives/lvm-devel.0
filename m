From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 24 Jan 2013 17:31:21 -0600
Subject: [RFC/PATCH 0/2] lvm2app: Adding lv creation support
In-Reply-To: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
References: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
Message-ID: <5101C449.60304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/23/2013 01:25 AM, M. Mohan Kumar wrote:
> From: "M. Mohan Kumar" <mohan@in.ibm.com>
> 
> Hello,
> 
> We added Block Device(BD) backend capability to GlusterFS last year. BD
> backend takes volume group as the input for GlusterFS volume and exports
> all logical volumes under it as regular files to the GlusterFS client.
> Now we are planning to export thin LVs as also regular files through
> GlusterFS. In order to support thin LVs, we need thin lv creation
> support in the lvm-devel.
> 
> I am posting RFC patches for adding various lv target creation
> support and thin(pool) lv creation support in lvm library.
> 
> First approach (Add thin and thin pool lv creation) adds two interfaces
> lvm_lv_thinpool and lvm_lv_thin (similar to lvm_vg_create_lv_linear())
> to create thin-pool LV and thin LV respectively.

Thanks for the patches!

This patch looks pretty straight forward.  Ideally we would not have the
function do the write and commit to match the other functions.  Did you
happen to take a peek to what that would involve?

> Second approach (Add LV creation support) adds interface
> lvm_vg_create_lv() that can be used to create LV of any target type
> (stripe, mirror, raid, thin etc). As part of this interface a new
> structure lv_params_t is addded which is similar to lvcreate_params
> exposing all parameters (such as chunk size, stripe size etc) to the end
> user. Advantage with this approach is that it gives the user to control
> properties of new LVs such as if the minor number of new lv should be
> persistent, allocation policy, permission mode, stripe size etc. But
> problem with this approach is that lots of code (parameter parsing,
> setting default value for LV properties etc) from tools is duplicated
> and it needs to be made as a library so that both tools and lvm-devel
> can consume them.
> 
> In the long run, lvm-devel may need to provide finer control to the user
> when creating LVs. In that case second approach is more suitable.

I agree with everything you state here and I also agree with your
comments about moving the code into a common spot instead of copying it.
 I see that you do have some slight differences in the copied functions,
but those are required.

Exposing parameter passing with the use of structures is typically
discouraged in a shared C API.  The struct padding can be different from
client application and library compile based on compiler settings.  If
we go this route we should at the very least do a pragma pack to
mitigate this.  In addition once you do this the structure forever
cannot change.  We could address these issues by creating an opaque data
type and then adding some functions to set/get the values from the
opaque handle.  Kind of tedious, but it is a common approach.

Not sure what else we could do to offset the vast number of arguments
that are available.

Regards,
Tony


