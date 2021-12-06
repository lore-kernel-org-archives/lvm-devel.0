From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Mon, 6 Dec 2021 14:57:24 +0100
Subject: thin vol write performance variance
In-Reply-To: <CAFe+wq1hhi9v3q09edkpg5eFf-8SNO2n8dLtY51TT1d3v-FO=Q@mail.gmail.com>
References: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
	<0e77c758-d804-61b6-73f1-3a268b03b6b2@redhat.com>
	<CAFe+wq2FRw7O_j0YeaKZANkPpqdus9DR675MO9Z42+kOiKPVyw@mail.gmail.com>
	<CAFe+wq2KVpPoESYEAhMW1dzzNSWRj6jwJ0m90bxA_AfW=UxvOg@mail.gmail.com>
	<CAFe+wq0k0HKJyngKQL6vgoZvW2Ht0xzDbFpnEgY43WeGWt42eg@mail.gmail.com>
	<CAFe+wq1hhi9v3q09edkpg5eFf-8SNO2n8dLtY51TT1d3v-FO=Q@mail.gmail.com>
Message-ID: <b99b0c5b-80ab-13d8-d1d9-207d1fe6aa89@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 06. 12. 21 v 7:11 Lakshmi Narasimhan Sundararajan napsal(a):
> Bumping this thread, any inputs would be appreciated.
> 
>>>>> Do you measure writes while provisioning thin chunks or on already provisioned
>>>>> device?
>>>>>
>>>>
>>>> Hi Zdenek,
>>>> These are traditional HDDs. Both the thin pool data/metadata reside on
>>>> the same set of drive(s).
>>>> I understand where you are going with this, I will look further into
>>>> defining the hardware/disk before I bring it to your attention.
>>>>
>>>> This run was not on an already provisioned device. I do see improved
>>>> performance of the same volume after the first write.
>>>> I understand this perf gain to be the overhead that is avoided during
>>>> the subsequent run where no mappings need to be established.
>>>>
>>>> But, you mentioned zeroing of provisioned blocks as an issue.
>>>> 1/ during lvcreate -Z from the man pages reports only controls the
>>>> first 4K block. And also implies this is a MUST otherwise fs may hang.
>>>> So, we are using this. Are you saying this controls zeroing of each
>>>> chunk that's mapped to the thin volume?

Yes - for 'lvcreate --type thin-pool' the option -Z controls 'zeroing' of 
thin-pool's thin volumes

The bigger the chunks are, the bigger the impact of zeroing will be.


>>>>
>>>> 2/ The other about zeroing all the data chunks mapped to the thin
>>>> volume, I could see only reference in the lvm.conf under
>>>> thin_pool_zero,
>>>> This is default enabled. So are you suggesting I disable this?

If you don't need it - disable it - it's kind of more secure to have it 
enabled - but if you use 'filesystem' like  ext4 on top - zeroing doesn't help 
as user of filesystem cannot read unwritten data. However if you read
device as root - you might be able to read 'stale' data from unwritten parts 
of data from provisioned chunks.


>>>>
>>>> Please confirm the above items. I will come back with more precise
>>>> details on the details you had requested for.
>>>>


As a side note - metadata device should preferabl sit on different spindle 
(SSD, nvme,...) as this is high-bandwith device and might frequently collide 
with your  _tdata volume writes.

Regrards

Zdenek


