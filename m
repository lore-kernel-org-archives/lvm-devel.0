From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Sat, 29 Jan 2022 21:05:43 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
	<aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
	<92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
Message-ID: <1b20e88f-2714-3c61-73a6-2f34f6a34edc@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29. 01. 22 v 0:21 Martin Wilck napsal(a):
> On Fri, 2022-01-28 at 22:06 +0100, Zdenek Kabelac wrote:
>> Dne 28. 01. 22 v 19:46 Martin Wilck napsal(a):
>>> On Fri, 2022-01-28 at 18:47 +0100, Zdenek Kabelac wrote:
>>>> Dne 28. 01. 22 v 17:02 Martin Wilck napsal(a):
>>>>> On Fri, 2022-01-28 at 16:57 +0100, Martin Wilck wrote:
> Well it is at the point we need to know exactly which device in which
>> state
>> causes you problem. Then we need to see what is wrong in the whole
>> process.
> 
> This is how multipathd loads the multipath map before the error occurs:
> 
> [  127.352614] localhost multipathd[1059]: 3600a098000aad1e300000b4b5a275d45: reload [0 134217728 multipath 3 pg_init_retries 50 queue_if_no_path 1 alua 2 1 service-time 0 1 1 8:80 1 service-time 0 2 1 8:16 1 8:144 1]

> 
>> All I'm saying here is - that the proposed patch is not fixing bug -
>> but
>> rather masking/minimizing window for error.
> 
> AFAICS my patch eliminates the window for this error entirely.


Ok now I see that there is already skip for DM_SUSPENDED
and you patch likely only tries to preserve some existing state of links.

I'll need to get in touch with Peter here.

I guess the idea behind was to avoid read of device that will be resumed and 
will automatically get a new event - and suspened device itself cannot change 
- but that fact it's been loosing existing state was missed - I'm wondering 
why this was not seen as problem before.


Regars

Zdene


