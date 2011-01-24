From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:08:13 +0100
Subject: liblvm Python/C extension (Python Liblvm)
In-Reply-To: <87oc77tb33.fsf@twilight.int.mornfall.net.>
References: <1295527769.24069.31.camel@ljonsson.local>
	<87oc77tb33.fsf@twilight.int.mornfall.net.>
Message-ID: <4D3D4F8D.5090305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.1.2011 01:11, Petr Rockai napsal(a):
> Hi,
> 
> Lars Sj?str?m <lars.sjostrom@redhat.com> writes:
>> I was missing a proper LVM2 interface to Python so I decided to write
>> one my self! I have wrapped all the liblvm C APIs (excluding the new
>> APIs committed in Dec). Doc strings are still missing, as well as proper
>> setup.py build env, so consider it as work in progress.
>>
>> This might also be interesting to other projects like Anaconda for
>> example.
>>
>> I would love to get your feedback on it!
> 
> I am not a python guy myself, but I definitely welcome this. On the
> other hand, as Zden?k points out, this does have some issues. I also
> think Anaconda folks have refused to use liblvm as far as there are no
> python bindings (and they are not interested in binding to the C API
> themselves). Hence, I suppose they are going to be interested indeed.
> 

I'm trying to get Anaconda team requirements in some written form - they are
doing many weird things which needs to be sorted out (currently they use some
rather very ugly hacks in their code) - I believe they do not need to handle
things in python at all as they do now and they should be happy with lvm2cmd
library - IMHO they need some virtual LVM support - but let's wait what will
they provide to us.

Zdenek


