From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 16 Oct 2009 15:00:53 -0400
Subject: [RFC][PATCH 1/5] support command string with space
In-Reply-To: <87zl8bd5h4.fsf@twilight.int.mornfall.net.>
References: <4AC2A619.50404@redhat.com>	<878wfwdvuj.fsf@twilight.int.mornfall.net.>	<4AC3CB45.1040503@redhat.com>
	<87zl8bd5h4.fsf@twilight.int.mornfall.net.>
Message-ID: <4AD8C2E5.6020105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/01/09 01:54, Petr Rockai wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
>> On 09/30/09 16:24, Petr Rockai wrote:
>>> IIUIC, the code will replace "\ " with "  " (double space) -- which may or may
>>> not be correct, depending on where the space appears. It also breaks any code
>>> that may have previously expected "\ " to have no special meaning, even though I
>>> doubt any exists.
>>
>> Yes, this approach replace "\ " with "  ", and it will work correctly unless
>> "\ " is used for other purpose previously. Current lvm codes use lvm_split()
>> only in early stage to split options and there is no case you concerns.
> There may not be *right now* -- I still think this is a bug waiting to
> happen. Shell scripts are full of escaping bugs and in dmeventd we have a
> simple way around (see below). One example for all -- I know it may be sick,
> but you can have device node paths with spaces in them, and I expect this will
> break -- either you forget to escape them, or the un-escaping produces wrong
> paths. (And as surprising as it may sound, spaces in device names work with
> current code -- I can create PVs and VGs on them and I can filter them out or
> in.)
> 
>>> Anyway, a more correct solution would entail a lvm2_runv (or similarly named)
>>> function, that would take char **argv -- no escaping issues to care
>>> about. Since this just adds to the library, it should be backwards compatible
>>> just fine.
>>
>> I can add an interface like lvm2_runv. But there is another approach using
>> single-quotes around an option with spaces as we do in a shell (e.g. bash).
> And how you quote single-quotes then? Doesn't work. Please use something
> reliable and robust -- like passing argv, or using varargs function (like
> execl). This eliminates all quoting bugs quite simply.

I see. Your approach, lvm2_runv, seems quite safe, and I will implement it.
Thank you for the helpful comments.

Thanks,
Taka


