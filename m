From: David Teigland <teigland@redhat.com>
Date: Thu, 14 Sep 2017 14:34:10 -0500
Subject: [Patch review 0/1] introduce lvm forcevg option to forcibly deactivate the whole vg
In-Reply-To: <b9660cb2-eae6-3b19-047b-4a8fa0235afb@redhat.com>
References: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
	<f74eba33-de77-2b26-31d1-5c103f4ec261@redhat.com>
	<20170914183914.GB31269@redhat.com>
	<b9660cb2-eae6-3b19-047b-4a8fa0235afb@redhat.com>
Message-ID: <20170914193410.GC31269@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Hmm - but script seems to be calling apps like umount - that isn't going
> cause issues ?

forcevg is not doing unmount because it would have problems (and we
wouldn't want to modify the system's filesystem namespace.)

> > Our particular use of this is as a helper script that sanlock runs when
> > the device holding the leases goes away, and the machine will be
> > imminently reset by the watchdog if we can't disable the LVs.  Given those
> > unique circumstances, we don't care about other lvm commands.  Is this
> > case is so specialized that it should be put in a separate script rather
> > than in blkdeactivate?
> 
> Wondering if there could be something for sharing for possibly usage in cases
> user wants to drop devices when thin-pool gets 'too full' and devices should
> be forcibly dropped even when they are in use...

That would be nice, if it could accomodate the unusual sanlock helper
requirements.


