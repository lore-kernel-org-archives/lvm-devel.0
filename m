From: Bill Nottingham <notting@redhat.com>
Date: Wed, 12 Sep 2012 11:19:45 -0400
Subject: master - systemd: depend on systemd-udev-settle unit in activation unit
In-Reply-To: <50507399.3010100@redhat.com>
References: <20120912093754.2FED74B0E@hosted02.fedoraproject.org>
	<50506DDA.10703@redhat.com> <50507399.3010100@redhat.com>
Message-ID: <20120912151945.GC3870@nostromo.devel.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha (prajnoha at redhat.com) said: 
> On 09/12/2012 01:11 PM, Zdenek Kabelac wrote:
> >> diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
> >> index 9fcee20..786d795 100644
> >> --- a/scripts/lvm2_activation_generator_systemd_red_hat.c
> >> +++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
> >> @@ -116,12 +116,12 @@ static int generate_unit(const char *dir, int early)
> >>             "DefaultDependencies=no\n", f);
> >>
> >>       if (early)
> >> -        fputs("After=fedora-wait-storage.service\n", f);
> >> +        fputs("After=systemd-udev-settle.service\n", f);
> >>       else
> >>           fputs("After=lvm2-activation-early.service cryptsetup.target\n", f);
> >>
> >>       fputs("Before=local-fs.target shutdown.target\n"
> >> -          "Wants=fedora-wait-storage.service\n\n"
> >> +          "Wants=systemd-udev-settle.service\n\n"
> >>             "[Service]\n"
> >>             "ExecStart=/usr/sbin/lvm vgchange -aay --sysinit\n"
> >>             "Type=oneshot\n", f);
> >>
> > 
> > 
> > I think we need here some backward compatible cross-distro solution.
> > 
> 
> The fedora-wait-storage.service itself was not quite perfect as
> it was only Fedora specific (therefore it's named
> lvm2_activation_generator_systemd_red_hat.c, having "red hat" in
> its name).
> 
> The fedora-wait-storage just called "modprobe scsi_wait_scan" which
> is not functional anymore as the module is gone now in recent kernels.
> 
> The dependency on systemd-udev-settle is far better and more
> cross-distro solution as we're actually waiting on udev to be settled.
> 
> The thing with scsi_wait_scan was only added in the way as
> an addendum to udev-settle functionality (as the next unit
> that is executed just after udev-settle).
> 
> If scsi_wait_scan stayed, then we'd better ask systemd
> upstream to include the unit with scsi_wait_scan there
> as an official unit distributed with systemd (but I think
> they counted with its removal so they did not bother to
> include it anymore). I haven't inspected where other
> distros called this scsi_wait_scan in their bootup process,
> if it was called at all there.
> 
> As for Fedora, F17 still uses fedora-wait-storage unit
> (having the modprobe scsi_wait_scan call), F18 and higher
> still has this unit, but it's failing as the module is not
> available anymore (the unit will be be removed soon I guess).
> 
> I think that for upstream solution, it's far better to depend
> on systemd-udev-settle.service. If there's anything else to
> wait for besides udev, it should be included in systemd upstream
> as an official and extra unit (so other distros would take that
> from systemd upstream when packaging).

Without scsi-wait-scan, I'm not sure that depending on udev-settle
will actually gain you much here - udev will have settled while
background scsi scans are still happening.

Bill


