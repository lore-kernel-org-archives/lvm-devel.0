From: Andy Grover <agrover@redhat.com>
Date: Sat, 15 Dec 2012 18:27:01 -0800
Subject: master - python-lvm: Make second lv.snapshot() argument optional
In-Reply-To: <50CCECF7.8000809@redhat.com>
References: <20121214221108.E6D52137F@hosted02.fedoraproject.org>
	<50CCECF7.8000809@redhat.com>
Message-ID: <50CD3175.5070803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/15/2012 01:34 PM, Zdenek Kabelac wrote:
> Dne 14.12.2012 23:11, Andy Grover napsal(a):
>> If no size is given, size defaults to 0, which in lvm_lv_snapshot will
>> allocate extents equal to the original LV be allocated for the new
>> snapshot.
>>
> 
> 
> Possibly not the ideal solution here.
> 
> 1) we have some clash with command line 'API'
>    user creates snapshot of thin volume
>       - without giving size he get thin volume snaphost.
>         lvcreate -s
>       - with size specified he gets 'old' snapshot
>         (snapshot outside of the pool)
>         lvcreate -s -l|-L

Makes sense. So should we do the same for the Python API -- size = None
-> thin snap, size = >=0 -> 'old' snap with the given size? OR might we
even be OK with just supporting 'new' snaps, and get rid of the size
parameter altogether?

Regards -- Andy


