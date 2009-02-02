From: Milan Broz <mbroz@redhat.com>
Date: Mon, 02 Feb 2009 18:15:56 +0100
Subject: [PATCH v2] Add --align parameter to pvcreate
In-Reply-To: <1233592128.5366.13.camel@localhost.localdomain>
References: <49804A78.3020302@redhat.com> <4982EAEC.9000209@redhat.com>
	<1233592128.5366.13.camel@localhost.localdomain>
Message-ID: <49872A4C.6090908@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski wrote:
>>  # Miscellaneous global LVM2 settings
>>  global {
>> -    
>> +
>>      # The file creation mask for any files and directories created.
>>      # Interpreted as octal if the first digit is zero.
>>      umask = 077
> 
> Uintended whitespace changes?

well, intended (whitespace cleaning),  but not necessary for patch:-)


>> -unsigned long pe_align(struct physical_volume *pv)
>> +unsigned long pe_align(struct physical_volume *pv, unsigned long force_pe_align)
> 
> 
> Inconsistent naming?  You have 'req_pe_align', 'align', and
> 'force_pe_align'.

...and physicalvolumealign_ARG, and pv_alignment in lvm.conf

I know, but if it is consistent in one place, it breaks somewhere else.
The idea was
	align is read from --align CLI parameter in pvcreate.c

(and is --align for commandline ok here?)

Others were just prefixes (req_/force_)

So if we have some name consistency rules, I'll rename it according it,
I just need to know these rules:-)

See for example this 
	pp->pe_start = pv_pe_start(existing_pv);
	pp->extent_size = pv_pe_size(existing_pv);
	pp->extent_count = pv_pe_count(existing_pv);

so pe_size or extent_size? align or pe_align or ... ?


>> +.BR \-\-align " size"
>> +Force align start of the payload to specified boundary (to align
>> +with underlying RAID device stripe or chunk).
>> +Note that you should use properly sized physical extent later
>> +in vgcreate to correctly align all Logical Volumes start too.
>> +.TP
> 
> Might be worth adding a sentence or two of how to query / derive this
> value.  I would guess someone will use this value, then want to verify
> it is set correctly.  I know we don't store it so we can't add it to the
> reporting code as a field but we can point out the use of pe_start and
> pe_size.

Yes, so I'll add

"To print the current data payload offset for the Physical Volume use
pvs -o +pe_start command.  The reported value is always multiple
of requested alignment value".

Any other suggestions?

> Ack other than the comments above.
> 
> I reviewed the whole patch and did limited testing.

Thanks for review!

Milan
--
mbroz at redhat.com


