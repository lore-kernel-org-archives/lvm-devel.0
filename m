From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 27 Mar 2013 10:23:17 +0100
Subject: pvresize problem
In-Reply-To: <20130326215001.GA15037@redhat.com>
References: <20130326165913.GA12503@redhat.com>
	<20130326215001.GA15037@redhat.com>
Message-ID: <5152BA85.1060001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 26.03.2013 22:50, David Teigland wrote:
> On Tue, Mar 26, 2013 at 12:59:13PM -0400, David Teigland wrote:
>> I'm trying to verify shrinking with pvresize --setphysicalvolumesize
>>
>> When the pv is an orphan, it works as expected, but when the pv is
>> not an orphan, the resulting size is always 8192S less than the
>> requested size.
> 
> Looking in _text_pv_resize(), I'm guessing the difference I see might be
> "pv->size -= size_reduction" which would indicate things are working as
> intended.  If so, I'll adjust my checks to include this reduction.
> 

Yes, exactly. When the PV is orphan, we're always reporting the size that
includes any alignments, metadata areas and PV headers (IOW, the "disk size
itself" or "pretended disk size" if the size was forced).

If the PV is in a VG, we're reporting only usable "data area" size, meaning the
size that is reserved for the data itself where extents can be allocated.

I can imagine this could cause confusion, but the problem is that it has been
reported this way since ages (though I don't know the exact historical reason
for this logic). The best would be if we could report the PV size for orphan
the same way as we do for non-orphans and then have an extra field that would
report the exact space used together with all the alignment and metadata...

(Though changing the PV size report for the orphan would mean changing existing
report which people can already use... Which is not a backward compatible
change unfortunately.)

Peter


