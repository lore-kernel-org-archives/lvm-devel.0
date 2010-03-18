From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 18 Mar 2010 01:05:10 +0000
Subject: [PATCH] Avoid scanning all pvs in the system if pvcreating on a device with mdas.
In-Reply-To: <87r5nj8d7b.fsf@twilight.int.mornfall.net.>
References: <1268778829-18908-1-git-send-email-dwysocha@redhat.com>
	<87r5nj8d7b.fsf@twilight.int.mornfall.net.>
Message-ID: <20100318010510.GD17615@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 17, 2010 at 11:17:12AM +0100, Peter Rockai wrote:
> Looks OK to me. As far as I can tell, it should never happen that the
> metadata is out-of-date and we overwrite a non-orphan PV mistakenly.
> This would require that the metadata on the PV claim this is an orphan
> but a newer copy of the metadata elsewhere claims this is part of a
> VG. That would mean that vgextend (or similar) failed to update the
> metadata on the new PV, which would presumably lead to overall vgextend
> failure and no new metadata on the pre-existing PVs either. So this
> should be safe.
 
There is actually a failure mode when this can happen.
The VG metadata is considered committed when the *first* vg_commit
occurs.  If the process dies at that point, the next vg_read of the VG
does automatic recovery which completes writing the correct VG metadata
to the remaining devices including the newly-added one.

So the optimisation in this patch assumes that if a process doing a
vgextend died at exactly the wrong point, there would be a vg_read
before this pv* code.  With a reboot or any sort of display command
a sysadmin would want to run after failure to check the state of
the system, this would happen.

So I'm not particularly concerned about that failure mode, and the logic
may change anyway when mdas are allowed to be empty.

Alasdair


