From: Eric Ren <zren@suse.com>
Date: Thu, 11 May 2017 10:21:06 +0800
Subject: Is it reasonable to build lvmlockd in this way?
In-Reply-To: <20170510163738.GA27800@redhat.com>
References: <87647df9-df19-8edd-1d60-7e99b9bcb12b@suse.com>
	<20170510163738.GA27800@redhat.com>
Message-ID: <a490c762-cf24-dffe-fce2-c9dc08fc1176@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

On 05/11/2017 12:37 AM, David Teigland wrote:
> On Wed, May 10, 2017 at 05:10:27PM +0800, Eric Ren wrote:
>> Hi David,
>>
>> Firstly, I really appreciate your work on lvmlockd feature. I've enabled it for openSUSE,
>> and have testing on it, which works great.
>>
>> But, we got a build problem on lvmlockd discussed here:
>>      https://bugzilla.suse.com/show_bug.cgi?id=1037309
>>
>> This is caused by the way openSUSE tries to build cluster-relative packages separately
>> by splitting spec file into different ones, in order to avoid dependencies when building
>> basic lvm packages:
>>      https://build.opensuse.org/package/show/Base:System/lvm2
>>
>> For cLVM, we can do it this way without problems. But, it cannot work for lvmlockd in this way,
>> because main lvm tools(like vgcreate) will link to the empty version of lvmlockd functions
>> (lockd_running_lock_type in lvmlockd.h).
>>
>> Our package team insists that we should change lvmlockd to the clvm way so that we can
>> build lvmlockd separately.   Before doing useless work, I really like to hear your advice first.
>>
>> Any comments would be appreciated!
> Hi, I'm a little out of my depth with build/packaging/distribution issues.
> First, I think you need to build with --enable-lvmlockd-dlm|sanlock, and
> provide the necessary bits of sanlock/dlm for building (the -devel
> subpackages of dlm and sanlock.)  It sounds like there's some aversion to
> doing this, but I don't see the problem.
Sorry, I didn't make the problem clear. Yes, it worked well when lvm and lvmlockd were built 
together.
The problem came up when our package team want to avoid dependencies on cluster-relative 
devel packages
at *building time*. They split lvm2.spec into 3 spec files: lvm2.spec[1], lvm2-clvm.spec[2] 
and device-mapper.spec[3]:

[1] https://build.opensuse.org/package/view_file/Base:System/lvm2/lvm2.spec?expand=1
[2] https://build.opensuse.org/package/view_file/Base:System/lvm2/lvm2-clvm.spec?expand=1
[3] https://build.opensuse.org/package/view_file/Base:System/lvm2/device-mapper.spec?expand=1

So, lvm tools are built in lvm2.spec without "BuildRequires" on clustering devels like 
corosync, dlm, sanlock,
while lvmlockd is built in lvm2-clvm.spec with all clustering things.

As a result, lvm tools will pull in the empty functions in lvmlockd.h [4] because 
"LVMLOCKD_SUPPORT" is not defined.

[4] 
https://sourceware.org/git/?p=lvm2.git;a=blob;f=lib/locking/lvmlockd.h;h=8b282d8c698a2b3cc18c81b4c152dc7d0b9e3e9b;hb=HEAD#l98

So every command using functions in lvmlockd.h will fail, even though wdmd, sanlock, 
lvmlockd are all ready. For example:

tw1:~ # vgcreate --shared vgtest /dev/vdb
	Using a shared lock type requires lvmlockd.
	Failed to detect a running lock manager to select lock type.

lockd_running_lock_type() is inlined the empty version into lvm tool in this case.


I know it's tricky to build lvmlockd in the way above. But, they ask me:
since lvm tools and cLVM can build this way, and run without problem, is it possible that 
lvm tools
can be built without linking to lvmlockd functions?

>
> Once it's built, we're putting the lvmlockd binary into a separate
> lvm2-lockd subpackage.  When built with lvmlockd support, lvm will still
Yes, we do the same.
> operate fine without lvmlockd present, it will just report an error if you
> try to use it.  I think this is what some of your references suggest.  I
> can understand wanting to avoid including lvmlockd/dlm/sanlock everywhere
> that lvm itself is needed, but putting lvmlockd into a separate package
> should avoid that.
Yes. But, our package team also want to reduce the dependencies when *building* basic lvm2 RPM.
Do you think it's something feasible?

Regards,
Eric
>
> Dave
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


