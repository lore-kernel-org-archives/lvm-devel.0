From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 13 Oct 2017 12:06:49 +0200
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
In-Reply-To: <20171013090842.28186-1-t.lamprecht@proxmox.com>
References: <20171013090842.28186-1-t.lamprecht@proxmox.com>
Message-ID: <0db6e3d2-4255-297f-46e0-72e729ee5da7@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.10.2017 v 11:08 Thomas Lamprecht napsal(a):
> Else, lvmetad always gets started due to systemds socket auto
> activation when executing, for example:
>   # pvscan --cache
> as pvscan uses lvmetad_is_disabled to check if metad is disabled
> before connecting. This is OK for systems where systemd is not used
> but for others, the systemd 'auto activation on socket connect'
> feature causes the start of lvm2-lvmetad.service which is not desired
> when disabled in the config.
> 
> ref: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826570
> Signed-off-by: Thomas Lamprecht <t.lamprecht@proxmox.com>
> ---
> 
> An alternative approach would be to just guard the lvmetad_is_disabled
> call in tools/pvscan.c : 412 with the config check - and thus address
> the FIXME mentioned there.
> Would be maybe the less intrusive version?
> 


Hi

The reason why is checked the presence for active service when lvmetad is 
disable is - we have to print warning that  lvmetad is there, but command is 
not going to use it/update it....

This may considerably harm lvmetad consistency.

If you want to avoid starting lvmetad systemd service - just mask this service 
- that's the correct way.


Regards

Zdenek


