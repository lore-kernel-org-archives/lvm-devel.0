From: Milan Broz <mbroz@redhat.com>
Date: Mon, 09 Aug 2010 18:28:17 +0200
Subject: [RFC PATCH v2] change default alignment of pe_start to 1MB
In-Reply-To: <20100806041138.GA29995@redhat.com>
References: <20100805191001.GA27237@redhat.com>
	<20100806041138.GA29995@redhat.com>
Message-ID: <4C602CA1.3040406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/06/2010 06:11 AM, Mike Snitzer wrote:
> The switch to a 1MB default alignment causes various tests in the LVM2
> testsuite to fail -- not a big deal but the tests would need updating.
> 
> Of more concern is that the existing LVM2 set_pe_align() code doesn't
> always properly respect the alignment determined from
> 'devices/md_chunk_alignment' or 'devices/data_alignment_detection'.
> 
> With the previous default alignment of 64k it would generally do the
> right thing -- use the detected values.  But switching the default to
> the larger value exposes the fact that MAX() of the MD or I/O Topology
> detected values will generally always be 1MB -- when they are compared
> to 1MB.
> 
> The following revised patch changes the LVM alignment detection
> semantics to model what fdisk has elected to do:
> - If the default value (1MB) is a multiple of the specified/detected
>   alignment then just use the default.
> - Otherwise, use the specified/detected value.
> 
> In practice this means we'll almost always use 1MB -- that is unless:
> - the specified --dataalignment, MD's full stripe width, or the
>   optimal_io_size exceeds 1MB
> - the specified/detected value is not a power-of-2

patch not tested, but Ack for idea.
(I just did independently the same for LUKS devices.)

Milan


