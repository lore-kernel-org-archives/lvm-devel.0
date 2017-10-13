From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 13 Oct 2017 15:25:11 +0200
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
In-Reply-To: <783e44c0-6836-ed8d-ee03-91f56ca0dce0@redhat.com>
References: <20171013090842.28186-1-t.lamprecht@proxmox.com>
	<0db6e3d2-4255-297f-46e0-72e729ee5da7@redhat.com>
	<c0d24b57-5f33-4b35-39ea-596db5028c37@proxmox.com>
	<783e44c0-6836-ed8d-ee03-91f56ca0dce0@redhat.com>
Message-ID: <a0fac9ef-9660-e4dc-4c94-3754be6dde5d@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/13/2017 02:04 PM, Zdenek Kabelac wrote:
> Dne 13.10.2017 v 13:23 Thomas Lamprecht napsal(a):
>> I must then mask also the socket as it has a require on the server.
>> As lvm2-monitor.service requires both, lvm2-lvmetad.service
>> lvm2-lvmetad.socket

Well, I think we can improve the ordering of the services a bit so we
can remove the "Requires: lvm2-lvmetad.socket" in lvm2-monitor.service
and just rely on the soft dependency with "After: lvm2-lvmetad.socket"
in lvm2-monitor.service. This would allow us to mask the
lvm2-lvmetad.socket without problems then.

Looking at this chart, I think we need to move the lvm2-lvmetad.socket
under local-fs-pre.target so we're sure it's prepared soon enough.

  https://www.freedesktop.org/software/systemd/man/bootup.html

I'll see if that helps and if yes, I'll post the patch.

-- 
Peter


