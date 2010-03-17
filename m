From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 13:32:27 -0400
Subject: [PATCH] Avoid scanning all pvs in the system if pvcreating on a device with mdas.
In-Reply-To: <87r5nj8d7b.fsf@twilight.int.mornfall.net.>
References: <1268778829-18908-1-git-send-email-dwysocha@redhat.com>
	<87r5nj8d7b.fsf@twilight.int.mornfall.net.>
Message-ID: <1268847147.2476.2.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2010-03-17 at 11:17 +0100, Petr Rockai wrote:
> Hi,
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > Other areas of the code check whether there are mdas on an orphan pv before
> > doing the expensive scan of the system.  This patch adds this check to pvcreate
> > as well, and so will avoid the unnecessary scan if pvcreate on a device that
> > is an orphan PV.
> Looks OK to me. As far as I can tell, it should never happen that the
> metadata is out-of-date and we overwrite a non-orphan PV mistakenly.
> 
> This would require that the metadata on the PV claim this is an orphan
> but a newer copy of the metadata elsewhere claims this is part of a
> VG. That would mean that vgextend (or similar) failed to update the
> metadata on the new PV, which would presumably lead to overall vgextend
> failure and no new metadata on the pre-existing PVs either. So this
> should be safe.
> 

Ok - turns out I should have searched more carefully as there are more
instances where we could save the scanning.

I'll work on an updated patch.




