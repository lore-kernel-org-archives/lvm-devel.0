From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 15 Feb 2018 14:20:02 +0100
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <df116b7f-2d69-38aa-a418-95137ba7e9b0@suse.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
	<d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
	<8bec25ed-2510-a31e-ba01-6bfd26257b52@suse.com>
	<b77058d3-386c-707e-a0e2-ef4f6c3e9ad6@redhat.com>
	<e26d3670-c6c5-ca07-eaf2-bbb3352bf28f@suse.com>
	<f3a6de00-6421-9fda-a4ff-3afb2bab0d5e@redhat.com>
	<df116b7f-2d69-38aa-a418-95137ba7e9b0@suse.com>
Message-ID: <12467e01-27ba-a4c3-2499-b5295b8c4c7b@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Got it.
>>
>> We did some more 'brainstorming' - with a result, that it actually doesn't
>> matter if LV is activate on more nodes - as long as there is cmirrord running,
>> and lvm2 is able to activate LV on multiple nodes - it should be always
>> possible to create proper tree mapping.
>>
>> But let's just see how it will work in reality - it will require some more 
>> thinking....
>>


Hi

I've pushed 2 new commits for pvmove and its clustered use-case.

So please give them some testing if you can spot something strange or if you 
think there could be some better logic behind it.

I've tried to accept wider range of active LVs - but it's for
further testing still whether it's got any better.

https://www.redhat.com/archives/lvm-devel/2018-February/msg00038.html
https://www.redhat.com/archives/lvm-devel/2018-February/msg00039.html

Regards

Zdenek


