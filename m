From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 5 Aug 2010 14:05:36 -0500
Subject: [PATCH] Never scan internal LVM devices.
In-Reply-To: <878w4mnzot.fsf@twilight.int.mornfall.net.>
References: <878w4mnzot.fsf@twilight.int.mornfall.net.>
Message-ID: <1EA2581F-C733-467C-8491-227A8C7E9D1C@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ACK. - many bugs are caused by this issue.

On Aug 4, 2010, at 10:51 AM, Petr Rockai wrote:

> Even if a PV was stacked in an LV, and this LV was composite (so it is
> using some internal LVs as its components), it is desirable that this
> *and only* this composite LV is seen by LVM as a PV. If the PV label  
> or
> MDA is propagated into the component LVs (such as mimages) and these  
> are
> found during a scan, this would lead to the PV being found multiple
> times which is certainly undesirable. Cf. the situation with MD
> component devices, which is analogous.

... and we have seen these cases when trying to stack VGs (e.g. a  
mirrored LV that forms the base of another VG).

  brassow


