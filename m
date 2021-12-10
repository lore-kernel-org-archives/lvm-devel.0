From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 10 Dec 2021 18:46:33 +0100
Subject: thin vol write performance variance
In-Reply-To: <CAFe+wq0REBKhgNkEtJf2mz+uok_emzVcWDH9bP=ccT8WkmYCpw@mail.gmail.com>
References: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
	<0e77c758-d804-61b6-73f1-3a268b03b6b2@redhat.com>
	<CAFe+wq2FRw7O_j0YeaKZANkPpqdus9DR675MO9Z42+kOiKPVyw@mail.gmail.com>
	<CAFe+wq2KVpPoESYEAhMW1dzzNSWRj6jwJ0m90bxA_AfW=UxvOg@mail.gmail.com>
	<CAFe+wq0k0HKJyngKQL6vgoZvW2Ht0xzDbFpnEgY43WeGWt42eg@mail.gmail.com>
	<CAFe+wq1hhi9v3q09edkpg5eFf-8SNO2n8dLtY51TT1d3v-FO=Q@mail.gmail.com>
	<b99b0c5b-80ab-13d8-d1d9-207d1fe6aa89@gmail.com>
	<CAFe+wq3g17abUGVz66-9BxB_dGWG3gQzjoWwHggJteNVPX_Ldw@mail.gmail.com>
	<CAFe+wq0REBKhgNkEtJf2mz+uok_emzVcWDH9bP=ccT8WkmYCpw@mail.gmail.com>
Message-ID: <c814fab6-3414-c562-497f-0739c6552029@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10. 12. 21 v 18:18 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi?Zdenek and team!
> 
> This issue looks very similar to dm block IO handling not using blkmq driver.
> IIRC the queue limits are not honoured for non blkmq devices.
> 
> So how can thin pool/thin dm devices be forced to use blkmq rq based device 
> driver?
> As noted in this thread, we are seeing a huge number of inflight IO on the dm 
> device and any sync takes a huge time to complete.
> Please advise.
> 
> As a reference I compared a root ssd with the thin device and the appropriate 
> sysfs dir(mq) is missing for dm devices, clearly indicating?that dm device do 
> not use blkmq rq based driver. See further logs below.

Hi

I'm not an thin target author - so can't tell technical detail - this would be 
question more for Joe & Mike - but AFAIK thin target do not support request 
based IO handling (like i.e. multipath).

Usage of thin target may cause amplification of writes - since a low number of 
write IO operation on this volume may cause considerable higher amount of real 
writes on _tmeta & _tdata LVs (i.e. COW of blocks - when you write to a chunk 
which is held by other thin snapshots) - note -  metadata typically *DO* 
require a separate FAST device.

Your setup looks like you seem to use same devices for _tmeta and _tdata LVs 
  (using same backend device 9:127 in your previous post)

Such configuration are NOT advised for any 'performance' oriented usage - 
there is no way around high bandwidth IO usage of the _tmeta device which 
simply needs frequent commits of updated metadata state - especially with 
larger metadata size this gets very very noticeable.

So my advice to try out would be to use different PVs for placement of _tdata
and _tmeta device - so writes are not going though same controller and  _tmeta 
use 'low-latency' device like SSD/NMVe.

If you are worried about to long time for sync - I'd consider to reduce amount 
of VM 'dirty' memory pages  (default linux kernel setting allows very high 
amount of your RAM hold unwritten data)

There is not much we can do on this side on thin - this is a nature of linux 
kernel device handling.

Also note - with using thin provisioning there is obviously some price being 
paid on hw utilization side - i.e. you can't expect 100% match with linear 
device. However once device is 'provisioned' and you write to those parts of 
device the performance should get very close to linear.

Also a simple rule of thumb - if you do not need snapshots - the bigger the 
chunks you use - the less 'metadata' handling you will see - i.e. using 
chunk-size of 512K causes significantly lower 'metadata' handling compared 
with default 64K chunk  (can be useful if you need to keep _tmeta & _tdata on 
same disk)  However - the bigger the chunk is - the less efficient the usage 
of snapshot gets as single byte change in 512K chunk requires to use new 512K 
chunk in thin-pool compared with 64K chunks.

Regards

Zdenek


