From: chris procter <chris-procter@talk21.com>
Date: Thu, 14 May 2009 22:36:07 +0000 (GMT)
Subject: Re: [PATCH v2] vgimportclone: script to import SAN snapshots and clones
In-Reply-To: <20090514043332.GA3032@redhat.com>
References: <1242253944-502-1-git-send-email-snitzer@redhat.com>
	<20090514002822.GD25793@agk-dp.fab.redhat.com>
	<20090514043332.GA3032@redhat.com>
Message-ID: <121786.54737.qm@web87104.mail.ird.yahoo.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit




> > I hate to go on about security, but have you tested that the script does not
> > misbehave even when you give it a PV with the nastiest set of characters you
> > can imagine in it?
> 
> I have not personally tested with nasty names but Chris did based on my
> feedback that PV names like the following are technically valid:
> pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
> 
> Chris contributed the code that symlinks the specified PV to
> $TMP_LVM_SYSTEM_DIR/vgimportX.
> 
> But I'll go over it.  Are you concerned about security or functionality?
> Or both?
> 
> Chris anything to add here?

Only that I've actually tried:
/dev/"__\"!@#\$%^&*,()|@||\\\""
/dev/*
/dev/''*   (with trailing space and single quotes)
/dev/$* ^"

(and probably some others I've forgotten)  as pv names and it handled them without issue.  It only actually uses the pv names while it create symlinks from more sensible names (the $TMP_LVM_SYSTEM_DIR/vgimportX names) which lvm.conf can handle, so functionalitywise I don't see a problem.  Securitywise, well I thought using /tmp/lvm/lvm.conf was safe so what do I know.

chris



      


