From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 23 Jan 2009 13:33:18 -0600
Subject: [PATCH 1/2] remove floating point values from lvm
In-Reply-To: <Pine.LNX.4.64.0901211055240.17174@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0901211055240.17174@hs20-bc2-1.build.redhat.com>
Message-ID: <8ACBAFF9-AC2F-4B80-9290-CB604D939B59@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I like the idea of getting rid of the floating point return value, but  
do we really have to introduce the 4 new return values?

  brassow

On Jan 21, 2009, at 9:57 AM, Mikulas Patocka wrote:

> Avoid depending on comparison of floating-point values. Return 4  
> values:
> TARGET_STATUS_ERROR --- error occured
> TARGET_STATUS_INVALIDATED --- the snapshot is invalidated (there may  
> still exist
> 	100% filled snapshot that is not invalidated)
> TARGET_STATUS_PROCESSING --- mirror is resynchronizing, snapshot is  
> neither
> 	empty nor invalidated.
> TARGET_STATUS_FINISHED --- finished. For mirrors, it is returned  
> when the mirror
> 	resynchronization finished. For snapshots, it is returned when the
> 	snapshot contains no exceptions (merging finished).
>
> Decisions are made based on these returned values, not on actual  
> floating point
> number.


