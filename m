From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 02 Jun 2010 11:22:02 +0200
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c ...
In-Reply-To: <4C062025.8020201@redhat.com>
References: <20100601160814.13230.qmail@sourceware.org>
	<4C062025.8020201@redhat.com>
Message-ID: <4C0622BA.90801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/02/2010 11:11 AM, Zdenek Kabelac wrote:
>> +    if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release)>=
>> +        KERNEL_VERSION(2, 6, 0))
>>           _dm_multiple_major_support = 0;
>>
> 
> 
> I think slightly better API would be here - to call some function like:
> 
> int is_kernel_version_higher(major, minor,relase);
> 
> Returns 1 if the kernel version is > than given argument.
> And keep _kernel_major local static in this function.

Yeah, exactly, I have this in my mind too :) I'll just gather all uses of
uname throughout the code and see what else we need and then I'll probably
try to export it, so it's central and we don't need to do these uname calls
and checks here and there...

Peter


